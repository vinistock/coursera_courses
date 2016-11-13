(function () {
    angular.module("MenuApp")
        .component("items", {
            templateUrl: "items.html",
            bindings: {
                items: "<"
            }
        });
})();
