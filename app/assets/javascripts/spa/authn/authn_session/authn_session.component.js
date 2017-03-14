(function () {
    "use strict";

    angular.module("spa.authn")
        .component("sdAuthnSession", {
           templateUrl: templateUrl,
            controller: AuthnSessionController
        });

    templateUrl.$inject = ["spa.config.APP_CONFIG"];
    function templateUrl (APP_CONFIG) {
        return APP_CONFIG.authn_session_html;
    }

    AuthnSessionController.$inject = ["$scope", "spa.authn.Authn"];
    function AuthnSessionController ($scope, Authn) {
        var vm = this;
        vm.loginForm = {};
        vm.login = login;
        vm.getCurrentUser = Authn.getCurrentUser;
        vm.getCurrentUserName = Authn.getCurrentUserName;

        vm.$onInit = function () {
            console.log("AuthnSessionController", $scope);
        };

        vm.$postLink = function () {
          vm.dropdown = $("#login-dropdown");
        };

        function login () {
            Authn.login(vm.loginForm).then(function () {
                vm.dropdown.removeClass("open");
            });
        }
    }
})();
