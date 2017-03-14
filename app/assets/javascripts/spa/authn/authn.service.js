(function () {
    "use strict";

    angular.module("spa.authn").service("spa.authn.Authn", Authn);

    Authn.$inject = ["$auth"];
    function Authn ($auth) {
        var service = this;
        service.signup = signup;
        service.user = null;
        service.isAuthenticated = isAuthenticated;
        service.getCurrentUser = getCurrentUser;
        service.getCurrentUserName = getCurrentUserName;
        service.login = login;
        service.logout = logout;

        activate();

        function activate () {
            $auth.validateUser().then(function (user) {
               service.user = user;
            });
        }

        function signup (registration) {
            return $auth.submitRegistration(registration);
        }

        function isAuthenticated () {
            return service.user && service.user["uid"];
        }

        function getCurrentUserName () {
            return service.user ? service.user.name : null;
        }

        function getCurrentUser () {
            return service.user;
        }

        function login (credentials) {
            var result = $auth.submitLogin({
                email: credentials["email"],
                password: credentials["password"]
            });

            result.then(function (response) {
                service.user = response;
            });

            return result;
        }

        function logout () {
            var result = $auth.signOut().then(function (response) {
                service.user = null;
            }, function (response) {
                service.user = null;
            });

            return result;
        }
    }
})();
