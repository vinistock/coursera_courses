(function () {
   "use strict";

    angular.module("spa.cities").directive("sdCities", CitiesDirective);

    CitiesDirective.$inject = ["spa.APP_CONFIG"];
    function CitiesDirective (APP_CONFIG) {
        return {
            templateUrl: APP_CONFIG.cities_html,
            replace: true,
            bindToController: true,
            controller: "spa.cities.CitiesController",
            controllerAs: "citiesCtrl",
            restrict: "E",
            scope: {},
            link: link
        };

        function link (scope, element, attrs) {
            console.log("CitiesDirective", scope);
        }
    }
})();
