(function () {
   "use strict";

    angular.module("spa.foos").directive("sdFoos", FoosDirective);

    FoosDirective.$inject = ["spa.config.APP_CONFIG"];
    function FoosDirective (APP_CONFIG) {
        return {
            templateUrl: APP_CONFIG.foos_html,
            replace: true,
            bindToController: true,
            controller: "spa.foos.FoosController",
            controllerAs: "foosCtrl",
            restrict: "E",
            scope: {},
            link: link
        };

        function link (scope, element, attrs) {
            console.log("FoosDirective", scope);
        }
    }
})();
