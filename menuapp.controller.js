(function () {
    angular.module("MenuApp").controller("MenuAppController", MenuAppController);

    MenuAppController.$inject = ["categories", "item"];
    function MenuAppController (categories, item) {
        var menuController = this;

        menuController.categories = categories;
        menuController.item = item;
        console.log(menuController.item);
    }
})();
