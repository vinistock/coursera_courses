(function () {
   angular.module("MenuApp").controller("ItemController", ItemController);

    ItemController.$inject = ["item"];
    function ItemController (item) {
        var itemController = this;

        itemController.item = item.menu_items;
    }
})();
