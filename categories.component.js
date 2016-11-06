(function () {
    angular.module("MenuApp")
        .component("categories", {
            templateUrl: "categories.html",
            controller: MenuAppController,
            bindings: {
                categories: "<"
            }
        });
})();
