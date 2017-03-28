(function() {
    "use strict";

    angular
        .module("spa.subjects")
        .directive("sdThingsAuthz", ThingsAuthzDirective);

    ThingsAuthzDirective.$inject = [];

    function ThingsAuthzDirective() {
        var directive = {
            bindToController: true,
            controller: ThingAuthzController,
            controllerAs: "vm",
            restrict: "A",
            scope: {
                authz: "="   //updates parent scope with authz evals
            },
            link: link
        };
        return directive;

        function link(scope, element, attrs) {
            console.log("ThingsAuthzDirective", scope);
        }
    }

    ThingAuthzController.$inject = ["$scope", "spa.subjects.ThingsAuthz"];
    function ThingAuthzController($scope, ThingsAuthz) {
        var vm = this;
        vm.authz={};
        vm.authz.canUpdateItem = canUpdateItem;

        ThingAuthzController.prototype.resetAccess = function() {
            this.authz.canCreate     = false;
            this.authz.canQuery      = false;
            this.authz.canUpdate     = false;
            this.authz.canDelete     = false;
            this.authz.canGetDetails = false;
            this.authz.canUpdateImage = false;
            this.authz.canRemoveImage = false;
        };

        activate();
        ////////////
        function activate() {
            vm.resetAccess();
            newUser();
        }

        function newUser(user, prevUser) {
            console.log("newUser=",user,", prev=",prevUser);
            vm.authz.authenticated = ThingsAuthz.isAuthenticated();
            if (vm.authz.authenticated) {
                vm.authz.canQuery      = true;
                vm.authz.canCreate     = true;
                vm.authz.canUpdate     = true;
                vm.authz.canDelete     = true;
                vm.authz.canGetDetails = true;
                vm.authz.canUpdateImage = true;
                vm.authz.canRemoveImage = true;
            } else {
                vm.resetAccess();
            }
        }

        function canUpdateItem(item) {
            return ThingsAuthz.isAuthenticated();
        }
    }
})();
