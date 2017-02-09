(function () {
    "use strict";

    angular.module("spa.foos").controller("spa.foos.FoosController", FoosController);

    FoosController.$inject = ["spa.foos.Foo"];
    function FoosController (Foo) {
        var ctrl = this;
        ctrl.edit = edit;
        ctrl.create = create;
        ctrl.update = update;
        ctrl.remove = remove;

        activate();

        function activate () {
            newFoo();
            ctrl.foos = Foo.query();
        }

        function newFoo () {
            ctrl.foo = new Foo();
        }

        function edit (object) {
            ctrl.foo = object;
        }

        function create () {
            ctrl.foo.$save().then(function (response) {
                ctrl.foos.push(ctrl.foo);
                newFoo();
            }).catch(handleError);
        }

        function update () {
            ctrl.foo.$update().then(function (response) {

            }).catch(handleError);
        }

        function remove () {
            ctrl.foo.$delete().then(function (response) {
               removeElement(ctrl.foos, ctrl.foo);
                newFoo();
            }).catch(handleError);
        }

        function removeElement(elements, element) {
            for (var i = 0; i < elements.length; i++) {
                if (elements[i].id == element.id) {
                    elements.splice(i, 1);
                    break;
                }
            }
        }

        function handleError () {

        }
    }
})();
