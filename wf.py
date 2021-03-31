import gnf

class Modules():

    @gnf.pretty_format
    def LEARN(self, **kwargs):
        return('''\
        workflow {child} {{
            main:
              eset = "${{params.indir}}/{eset}"
              modules = "${{params.indir}}/{mods}"
              SPLIT( eset, modules )
              LEARN( SPLIT.out.flatten() )
              RECONSTRUCT( eset, LEARN.out[0].collect() )
            emit:
              LEARN.out[0]
        }}
        '''.format(**kwargs))

    @gnf.pretty_format
    def LEARN_PRIOR(self, **kwargs):
        return('''\
        workflow {child} {{
            take: 
              prior
            main:
              eset = "${{params.indir}}/{eset}"
              LEARN_PRIOR( eset, prior )
              RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
            emit:
              LEARN_PRIOR.out[0]
        }}
        '''.format(**kwargs))

# Read data and define hierarchy
df = gnf.read_data("data/data.csv")
tree = gnf.build_tree(df)
gnf.print_tree(tree)

# Create the workflow dependencies
m = Modules()
for node in gnf.traverse_tree(tree):
    module = getattr(m, node.module)
    print(module(**node.kwargs))

# Create main workflow
print("workflow {")
for node in gnf.traverse_tree(tree):
    try:
        print("  {0}( {1}.out )".format(node.kwargs['child'], node.kwargs['parent']))
    except KeyError:
        print("  {0}()".format(node.kwargs['child']))
print("}")
