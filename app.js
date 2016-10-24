(function () {
    angular.module("ShoppingListCheckOff", [])
        .controller("controller1", controller1)
        .controller("controller2", controller2)
        .service("ShoppingListCheckOffService", ShoppingListCheckOffService);

    controller1.$inject = ["ShoppingListCheckOffService"];
    controller2.$inject = ["ShoppingListCheckOffService"];

    function ShoppingListCheckOffService () {
        var bought = [];
        var toBuy = [
            { name: "cookies", quantity: 10 },
            { name: "chips", quantity: 2 },
            { name: "soda bottles", quantity: 5 },
            { name: "nacho bags", quantity: 3 },
            { name: "juice bottles", quantity: 2 }
        ];

        this.getBought = function () {
            return bought;
        };

        this.getToBuy = function () {
            return toBuy;
        };

        this.addBought = function (index) {
            var item = toBuy[index];
            bought.push(item);
            toBuy.splice(index, 1);
        };
    }

    function controller1 (ShoppingListCheckOffService) {
        this.toBuy = ShoppingListCheckOffService.getToBuy();

        this.addBought = function (index) {
            ShoppingListCheckOffService.addBought(index);
        }
    }

    function controller2 (ShoppingListCheckOffService) {
        this.bought = ShoppingListCheckOffService.getBought();
    }
})();
