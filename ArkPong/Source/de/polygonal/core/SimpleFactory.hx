package de.polygonal.core;
class SimpleFactory implements DynamicPoolFactory{
    private var _class:Class;
    public function new(C:Class) {
        _class=C;
    }

    public function create():Dynamic
    {
        return Type.createInstance(_class);
    }
}
