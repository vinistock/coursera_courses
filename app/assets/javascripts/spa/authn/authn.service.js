(function () {
    "use strict";

    angular.module("spa.authn").service("spa.authn.Authn", Authn);

    Authn.$inject = ["$auth", "$q"];
    function Authn ($auth, $q) {
        var service = this;
        service.signup = signup;
        service.user = null;
        service.isAuthenticated = isAuthenticated;
        service.getCurrentUser = getCurrentUser;
        service.getCurrentUserName = getCurrentUserName;
        service.getCurrentUserId = getCurrentUserId;
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
            return service.user != null && service.user["uid"] != null;
        }

        function getCurrentUserName () {
            return service.user ? service.user.name : null;
        }

        function getCurrentUser () {
            return service.user;
        }

        function getCurrentUserId () {
            return service.user != null ? service.user.id : null;
        }

        function login (credentials) {
            var result = $auth.submitLogin({
                email: credentials["email"],
                password: credentials["password"]
            });

            var deferred = $q.defer();

            result.then(function (response) {
                service.user = response;
                deferred.resolve(response);
            }, function (response) {
                var formatted_errors = { errors: { full_messages: response.errors } };
                deferred.reject(formatted_errors);
            });

            return deferred.promise;
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
