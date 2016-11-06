(function () {
   angular.module("MenuApp").controller("ItemController", ItemController);

    ItemController.$inject = ["item"];
    function ItemController (item) {
        var itemController = this;

        itemController.item = item;
        console.log(itemController.item);
    }
})();
