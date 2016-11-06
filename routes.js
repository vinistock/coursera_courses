(function () {
    angular.module("MenuApp").config(Routes);

    Routes.$inject = ["$stateProvider", "$urlRouterProvider"];
    function Routes ($stateProvider, $urlRouterProvider) {
        $urlRouterProvider.otherwise("/");

        $stateProvider
            .state("home", {
                url: "/",
                template: "<h3>Home</h3>"
            })
            .state("categories", {
                url: "/categories",
                templateUrl: "categories.html",
                controller: "MenuAppController as menuController",
                resolve: {
                    categories: ["MenuDataService", function (MenuDataService) {
                        return MenuDataService.getAllCategories();
                    }]
                }
            });
    }
})();
