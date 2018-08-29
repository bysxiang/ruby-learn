p Module.singleton_class.superclass.class

p BasicObject.instance_methods(false).grep(/include/)

p Object.instance_methods(false).grep(/include/)

p Class.instance_methods(false).grep(/include/)


p Module.private_instance_methods(false).grep(/include/)

p Module.singleton_class.private_instance_methods(false).grep(/include/)