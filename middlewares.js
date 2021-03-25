"use strict"

module.exports = {
    checkSession: function(request, response, next){
        if (request.session.currentName !== undefined && request.session.currentEmail  !== undefined && request.session.currentID !== undefined && request.session.currentImg !== undefined) {
            response.locals.userName    = request.session.currentName;
            response.locals.userEmail   = request.session.currentEmail;
            response.locals.userID      = request.session.currentID;
            response.locals.userImg     = request.session.currentImg;
            next();
        } else {
            response.redirect("/loginout/login");
        }
    },

    middlewareNotFoundError: function(request, response, next){
        response.status(404);
        response.render("error_404");
    },
    
    middlewareServerError: function(error, request, response, next){
        console.log(error);
        response.status(500);
        response.render("error_500");
    }
}