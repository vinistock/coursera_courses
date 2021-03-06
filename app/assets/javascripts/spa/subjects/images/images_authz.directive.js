(function () {
    "use strict";

    angular.module("spa.subjects").directive("sdImagesAuthz", ImagesAuthz);

    ImagesAuthz.$inject = [];
    function ImagesAuthz () {
        var directive = {
            bindToController: true,
            controller: ImagesAuthzController,
            controllerAs: "vm",
            restrict: "A",
            scope: {
                authz: "="
            },
            link: link
        };

        return directive;

        function link (scope, element, attrs) {
            console.log("ImagesAuthzDirective", scope);
        }
    }

    ImagesAuthzController.$inject = ["$scope", "spa.subjects.ImagesAuthz"];
    function ImagesAuthzController ($scope, ImagesAuthz) {
        var vm = this;
        vm.authz = {};
        vm.authz.canUpdateItem = canUpdateItem;
        vm.newItem = newItem;

        activate();

        function activate () {
            vm.newItem(null);
        }

        function newItem (item) {
            ImagesAuthz.getAuthorizedUser().then(
                function (user) { authzUserItem(item, user); },
                function (user) { authzUserItem(item, user); })
        }

        function authzUserItem (item, user) {
            vm.authz.authenticated = ImagesAuthz.isAuthenticated();
            vm.authz.canQuery = ImagesAuthz.canQuery();
            vm.authz.canCreate = ImagesAuthz.canCreate();

            if (item && item.$promise) {
                vm.authz.canUpdate = false;
                vm.authz.canDelete = false;
                vm.authz.canGetDetails = false;
                item.$promise.then(function() { checkAccess(item) });
            } else {
                checkAccess(item);
            }
        }

        function checkAccess (item) {
            vm.authz.canUpdate = ImagesAuthz.canUpdate(item);
            vm.authz.canDelete = ImagesAuthz.canDelete(item);
            vm.authz.canGetDetails = ImagesAuthz.canGetDetails(item);
        }

        function newUser(user, prevUser) {
            vm.authz.canQuery = true;
            vm.authz.authenticated = ImagesAuthz.isAuthenticated();

            if (vm.authz.authenticated) {
                vm.authz.canCreate = true;
                vm.authz.canUpdate = true;
                vm.authz.canDelete = true;
                vm.authz.canGetDetails = true;
            } else {
                vm.resetAccess();
            }
        }

        function canUpdateItem (item) {
            return ImagesAuthz.isAuthenticated();
        }
    }
})();
