(function (){
    angular.module("NarrowItDownApp", [])
        .controller("controller1", controller1)
        .service("MenuSearchService", MenuSearchService)
        .directive("foundItems", foundItems);

    function foundItems () {
        var ddo = {
            templateUrl: "found_items.html",
            scope: {
                foundItems: "<",
                onRemove: "&"
            },
            controller: controller1,
            controllerAs: "items",
            bindToController: true
        };
        
        console.log(ddo);

        return ddo;
    }

    MenuSearchService.$inject = ["$http"];
    function MenuSearchService ($http) {
        this.getMatchedMenuItems = function (searchTerm) {
            var foundItems = [];
            var response = $http({
                method: "GET",
                url: "https://davids-restaurant.herokuapp.com/menu_items.json"
            }).then(function (response) {
                for (var i = 0; i < response.data.menu_items.length; i++) {
                    if (response.data.menu_items[i].description.includes(searchTerm)) {
                        foundItems.push(response.data.menu_items[i]);
                    }
                }

                return foundItems;
            });
        }
    }

    controller1.$inject = ["$scope", "MenuSearchService"];
    function controller1 ($scope, MenuSearchService) {
        $scope.found = [];

        $scope.searchIt = function () {
            $scope.found = MenuSearchService.getMatchedMenuItems($scope.query);
        };

        $scope.removeItem = function (index) {
            $scope.found.splice(1, index);
        };
    }
})();
