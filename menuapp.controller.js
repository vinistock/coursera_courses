(function () {
    angular.module("MenuApp").controller("MenuAppController", MenuAppController);

    MenuAppController.$inject = ["categories"];
    function MenuAppController (categories) {
        var menuController = this;

        menuController.categories = categories;
        console.log(categories);
    }
})();
