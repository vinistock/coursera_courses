(function () {
    "use strict";

    angular.module("spa.cities").controller("spa.cities.CitiesController", CitiesController);

    CitiesController.$inject = ["spa.cities.City"];
    function CitiesController (City) {
        var ctrl = this;
        ctrl.edit = edit;
        ctrl.create = create;
        ctrl.update = update;
        ctrl.remove = remove;

        activate();

        function activate () {
            newCity();
            ctrl.cities = City.query();
        }

        function newCity () {
            ctrl.city = new City();
        }

        function edit (object) {
            ctrl.city = object;
        }

        function create () {
            ctrl.city.$save().then(function (response) {
                ctrl.cities.push(ctrl.city);
                newCity();
            }).catch(handleError);
        }

        function update () {
            ctrl.city.$update().then(function (response) {

            }).catch(handleError);
        }

        function remove () {
            ctrl.city.$delete().then(function (response) {
               removeElement(ctrl.cities, ctrl.city);
                newCity();
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
