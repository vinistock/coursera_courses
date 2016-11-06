(function () {
    angular.module("MenuApp").config(Routes);

    Routes.$inject = ["$stateProvider", "$urlRouterProvider"];
    function Routes ($stateProvider, $urlRouterProvider) {
        $urlRouterProvider.otherwise("/");

        $stateProvider
            .state("home", {
                url: "/",
                template: "<h3>Welcome to our Restaurant!</h3>"
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
            })
            .state("items", {
                url: "/items/{id}",
                templateUrl: "item.html",
                controller: "ItemController as itemController",
                resolve: {
                    item: ["$stateParams", "MenuDataService", function ($stateParams, MenuDataService) {
                        return MenuDataService.getAllCategories().then(function (response) {
                            return response[$stateParams.id];
                        });
                    }]
                }
            });
    }
})();
