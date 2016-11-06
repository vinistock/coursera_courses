(function () {
    angular.module("MenuApp").controller("MenuAppController", MenuAppController);

    MenuAppController.$inject = ["categories"];
    function MenuAppController (categories) {
        var controller = this;

        controller.categories = categories;
    }
})();
