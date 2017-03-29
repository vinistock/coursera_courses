(function () {
    "use strict";

    angular.module("spa.subjects").factory("spa.subjects.TripsAuthz", TripsAuthzFactory);

    TripsAuthzFactory.$inject = ["spa.authz.Authz", "spa.authz.BasePolicy"];
    function TripsAuthzFactory (Authz, BasePolicy) {
        function TripsAuthz () {
            BasePolicy.call(this, "Trip");
        }

        TripsAuthz.prototype = Object.create(BasePolicy.prototype);
        TripsAuthz.constructor = TripsAuthz;

        TripsAuthz.prototype.canQuery = function () {
            return Authz.isAuthenticated();
        };

        TripsAuthz.prototype.canAddImage = function (trip) {
            return Authz.isMember(trip);
        };

        TripsAuthz.prototype.canUpdateImage = function (trip) {
            return Authz.isOrganizer(trip);
        };

        TripsAuthz.prototype.canRemoveImage = function (trip) {
            return Authz.isOrganizer(trip) || Authz.isAdmin();
        };

        return new TripsAuthz();
    }
})();
