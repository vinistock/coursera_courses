(function (){
    angular.module("NarrowItDownApp", [])
        .controller("controller1", controller1)
        .service("MenuSearchService", MenuSearchService)
        .directive("foundItems", foundItems);

    function foundItems () {
        var ddo = {
            templateUrl: 'found_items.html',
            scope: {
                items: '<',
                onRemove: '&'
            },
            controller: controller1,
            controllerAs: 'list',
            bindToController: true
        };

        return ddo;
    }

    MenuSearchService.$inject = ["$http"];
    function MenuSearchService ($http) {
        this.getMatchedMenuItems = function (searchTerm) {
            return $http({
                method: "GET",
                url: "https://davids-restaurant.herokuapp.com/menu_items.json"
            }).then(function (response) {
                var foundItems = [];

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
            MenuSearchService.getMatchedMenuItems($scope.query).then(function (response) {
                $scope.found = response;
            });
        };

        $scope.removeItem = function (index) {
            $scope.found.splice(1, index);
        };
    }
})();
