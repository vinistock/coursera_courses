(function () {
    angular.module("LunchCheck", [])
        .controller("lunchCheckController", lunchCheckController);


    lunchCheckController.$inject = ["$scope"];

    function lunchCheckController ($scope) {
        $scope.lunchMessage = "";

        $scope.checkLunch = function () {
          if ($scope.lunchItems == "" || $scope.lunchItems == undefined) {
              $scope.lunchMessage = "Please enter data first";
          } else if ($scope.lunchItems.split(",").length > 3) {
              $scope.lunchMessage = "Too much!";
          } else {
              $scope.lunchMessage = "Enjoy!";
          }
        };
    }
})();