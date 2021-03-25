"use strict"

const path          = require('path');
const pool          = require("../database");
const DAOUsers      = require('../models/modelUsuarios');
let daoUsers        = new DAOUsers(pool);

module.exports = {
    // Ruta: /loginout/registro
    getRegisterRedirect: function(request, response){
        response.render("register", { errorMsg : null });
    },

    // Ruta: /loginout/login
    getLoginRedirect: function(request, response){
        response.render("login", { errorMsg : null });
    },

    // Ruta: POST a la bbdd del register
    registerUser: function(request, response){
        let data = {
            email       : request.body.email,
            username    : request.body.username,
            password    : request.body.password,
            password_c  : request.body.password_confirm,
            profileImg  : request.file
        };
        if(data.profileImg){
            data.profileImg = data.profileImg.filename // nombre del fichero, luego para obtener las imgs se hace a traves de /imagen/:id
        }
    
        if(data.password === data.password_c){
            if(data.username === '' || data.email === '' || data.password === '' || data.password_c === ''){
                response.render("register", { errorMsg : 'Rellena todos los campos obligatorios marcados con *' });
            } else{
                daoUsers.createUser(data, function (error) {
                    if (error) {
                        response.status(500);
                        response.render("error_500");
                    } else {
                        response.redirect("/loginout/login");
                    }
                });
            }
        } else{
            response.render("register", { errorMsg : 'Las contraseñas no coinciden.' });
        }
    },

    // Ruta: POST a la bbdd para iniciar la sesion
    loginUser: function(request, response){
        daoUsers.isUserCorrect(request.body.email, request.body.password, function(error, user){
            if(error){
                response.status(500);
                response.render("error_500");
            } else if(user !== null){
                request.session.currentName     = user.username;
                request.session.currentEmail    = user.email;
                request.session.currentID       = user.id;
                request.session.currentImg      = user.profileImg;
                response.redirect("/index");
            } else{
                response.render("login", { errorMsg : "Dirección de correo electrónico y/o contraseña no válidos" });
            }
        });
    },

    // Ruta: POST /loginout/logoutUser
    logoutUser: function(request, response){
        request.session.destroy();
        response.redirect("/loginout/login");
    }
}