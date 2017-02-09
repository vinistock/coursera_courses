(function () {
    "use strict";

    angular.module("spa").config(Router);

    Router.$inject = ["$stateProvider", "$urlRouterProvider", "spa.APP_CONFIG"];

    function Router ($stateProvider, $urlRouterProvider, APP_CONFIG) {
        $stateProvider
            .state("home", {
                url: "/",
                templateUrl: APP_CONFIG.main_page_html
            });

        $urlRouterProvider.otherwise("/");
    }
})();
