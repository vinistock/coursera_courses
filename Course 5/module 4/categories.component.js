(function () {
    angular.module("MenuApp")
        .component("categories", {
            templateUrl: "categories.html",
            bindings: {
                categories: "<"
            }
        });
})();
