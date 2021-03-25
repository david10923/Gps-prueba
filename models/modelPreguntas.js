"use strict"

const moment = require('moment'); // Formatear fechas

class DAOQuestions{

    constructor(pool){
        this.pool = pool;
    }

    // Ordenar un array de preguntas por FECHA mas reciente
    static orderQuestions(arr){
        let response = arr;
        response.sort(function(a, b){
            if(a.date > b.date){
                return -1;
            } if(a.date < b.date){
                return 1;
            }
            return 0;
        });
        return response;
    }

    createQuestion(data, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                connection.query("INSERT INTO questions(`user`, `title`, `body`) VALUES (?,?,?)", [ data.email, data.title, data.body ] , function(error, result){
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        var questionID = result.insertId;
                        if(data.tags.length > 0){
                            let queryStr = "INSERT INTO tags (question,tagName) VALUES ?;", params = [];
                            for(var i = 0; i < data.tags.length; i++){
                                params.push([ questionID, data.tags[i] ]);
                            }
                            connection.query(queryStr, [ params ], function(error){
                                connection.release();
                                if(error){
                                    callback(new Error("Error de acceso a la base de datos tags"));
                                } else{
                                    callback(null);
                                }
                            });
                        } else{
                            connection.release();
                            callback(null);
                        }
                    }
                });
            }
        });
    }

    
    // ORDENARLAS CRONOLOGICAMENTE
    readAllQuestion(callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                let sql1 = "SELECT q.ID, q.user, q.title, q.body, q.date, u.username, u.profileImg as userImg, u.id as userID FROM questions q JOIN users u ON q.user=u.email WHERE q.user=u.email;";
                let sql2 = "SELECT t.tagName, t.question FROM tags t JOIN questions q WHERE q.ID=t.question;";
                let sql = sql1 + sql2;
                connection.query(sql, function(error, results, fields){
                    connection.release();
                    if(error){
                        callback(error);
                    } else{
                        let questions   = {},
                            response    = [];
                        // Formateamos nuestro objeto
                        results[0].forEach(function(question){
                            question.tags = [];
                            question.date = moment(question.date).format('YYYY-MM-DD HH:mm:ss');
                            if(question.body.length > 150){
                                question.body = question.body.slice(0, 150) + '...';
                            }
                            questions[question.ID] = question;
                        });
                        results[1].forEach(function(tag){
                            questions[tag.question].tags.push(tag.tagName);
                        });
                        
                        // Formateamos la salida
                        for (const [ k, v ] of Object.entries(questions)) {
                            response.push(v);
                        }
                        
                        response = DAOQuestions.orderQuestions(response);

                        callback(false, { totalQuestions: response.length, questions: response });
                    }
                });
            }
        });
    }

    filterQuestionByTag(tagName, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                let sql1 = "SELECT t.question FROM tags t JOIN questions q WHERE q.ID=t.question AND t.tagName=?;";
                let sql2 = "SELECT q.ID, q.user, q.title, q.body, q.date, u.username, u.profileImg as userImg, u.id as userID FROM questions q JOIN users u WHERE q.user=u.email ORDER BY q.date DESC;";
                let sql3 = "SELECT t.tagName, t.question FROM tags t JOIN questions q WHERE q.ID=t.question;";
                let sql = sql1 + sql2 + sql3;
                connection.query(sql, [ tagName ] , function(error, results){
                    connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        let tags        = {}, // todos los tags de cada pregunta
                            response    = []; // todas las preguntas
                        results[0].forEach(function(tag){
                            tags[tag.question] = [];
                        });
                        results[2].forEach(function(tag){
                            if(tags[tag.question]){
                                tags[tag.question].push(tag.tagName);
                            }
                        });
                        results[1].forEach(function(question){
                            if(tags[question.ID]){
                                question.date = moment(question.date).format('YYYY-MM-DD HH:mm:ss');
                                question.tags = tags[question.ID];
                                if(question.body.length > 150){
                                    question.body = question.body.slice(0, 150) + '...';
                                }
                                response.push(question);
                            }
                        });

                        callback(false, { totalQuestions: response.length, questions: DAOQuestions.orderQuestions(response) });
                    }
                });
            }
        });

    }

    createAnswer(data, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                connection.query("INSERT INTO `answers`(`user`, `question`) VALUES (?,?)", [ data.email, data.id ] , function(error, result){
                    connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        callback(false, result);
                    }
                });
            }
        });
    }

    findByFilter(text, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                let sql1 = "SELECT q.ID, q.user, q.title, q.body, q.date, u.username, u.profileImg as userImg, u.id as userID FROM questions q JOIN users u WHERE q.user=u.email AND (q.title LIKE ? OR q.body LIKE ?);";
                let sql2 = "SELECT t.tagName, t.question FROM tags t JOIN questions q WHERE q.ID=t.question;";
                let sql = sql1 + sql2;
                connection.query(sql, [ text, text ] , function(error, results){
                    connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        let questions   = {},
                            response    = [];
                        // Formateamos nuestro objeto
                        results[0].forEach(function(question){
                            question.tags = [];
                            question.date = moment(question.date).format('YYYY-MM-DD HH:mm:ss');
                            if(question.body.length > 150){
                                question.body = question.body.slice(0, 150) + '...';
                            }
                            questions[question.ID] = question;
                        });
                        results[1].forEach(function(tag){
                            if(questions[tag.question]){
                                questions[tag.question].tags.push(tag.tagName);
                            }
                        });
                        
                        // Formateamos la salida
                        for (const [ k, v ] of Object.entries(questions)) {
                            response.push(v);
                        }
                        // console.log(response);
                        callback(false, { totalQuestions: response.length, questions: DAOQuestions.orderQuestions(response) });
                    }
                });
            }
        });
    }

    // INCREMENTAR EN 1 EL NUMERO DE VISITAS A LA PREGUNTA PARA EL USUARIO ACTUAL SI NO LA HA VISITADO ANTES
    filterQuestionByID(params, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                connection.query("SELECT COUNT(*) as filas FROM visits v WHERE v.question=? AND v.user=?", [ params.question, params.user ], function(error, results){
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        // console.log(results);
                        let sql1 = '', sql2 = '', sql3 = '', queryParams = [];
                        if(results[0].filas === 0){ // sumar visita
                            sql1 = "INSERT INTO visits(question, user) VALUES(?,?);";
                            queryParams.push(params.question, params.user);
                        }
                        sql1 += "SELECT q.ID as qID, q.title, q.body, q.date, q.visits, q.nLikes, q.nDislikes, u.ID as qUserID, u.profileImg, u.username FROM questions q JOIN users u WHERE q.user=u.email AND q.ID=?;";
                        sql2 = "SELECT t.tagName FROM tags t WHERE t.question=?;";
                        sql3 = "SELECT a.ID as aID, u.username as aUser, a.body, a.nLikes, a.nDislikes, a.date, u.ID as userID, u.profileImg FROM answers a JOIN users u WHERE a.user=u.email AND a.question=?;";
                        queryParams.push(params.question, params.question, params.question);

                        connection.query(sql1 + sql2 + sql3, queryParams, function(error, results){
                            connection.release();
                            if(error){
                                callback(new Error("Error de acceso a la base de datos"));
                            } else{
                                let total = results.length;
                                let q = results[total - 3][0];
                                q.tags = [];
                                q.date = moment(q.date).format('YYYY-MM-DD HH:mm:ss');
                                results[total - 2].forEach(function(tag){ q.tags.push(tag.tagName); });
                                results[total - 1].forEach(function(answer){ answer.date = moment(answer.date).format('YYYY-MM-DD HH:mm:ss'); });
                                callback(null, { question: q, answers: results[total - 1] });
                            }
                        });
                    }
                });
            }
        });
    }

    postAnswer(params, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{               
                connection.query("INSERT INTO answers(user, question, body) VALUES (?,?,?)", [ params.user, params.question, params.text ], function(error, results){
                    connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        callback(null);
                    }
                });
            }
        });
    }

    scoreQuestion(params, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                connection.query("SELECT COUNT(*) as filas FROM questions_score q WHERE q.question=? AND q.user=?", [ params.question, params.user ], function(error, results){
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        let sql = '', queryParams = [];
                        if(results[0].filas === 0){ // insertar
                            sql = "INSERT INTO questions_score(question,user,type) VALUES(?,?,?);";
                            queryParams.push(params.question, params.user, params.type);
                            connection.query(sql, queryParams, function(error, results){
                                connection.release();
                                if(error){
                                    callback(new Error("Error de acceso a la base de datos"));
                                } else{
                                    callback(null);
                                }
                            });
                        } else{
                            connection.release();
                            callback(null);
                        }
                    }
                });
            }
        });
    }

    noAnswers(callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                let sql0 = "SELECT DISTINCT(question) FROM answers";
                let sql1 = `SELECT q.ID, q.user, q.title, q.body, q.date, u.username, u.profileImg as userImg, u.id as userID FROM questions q JOIN users u WHERE q.user=u.email AND q.ID NOT IN (${sql0});`;
                let sql2 = "SELECT t.tagName, t.question FROM tags t JOIN questions q WHERE q.ID=t.question;";
                connection.query(sql1 + sql2, function(error, results, fields){
                    connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        let questions   = {},
                            response    = [];
                        // Formateamos nuestro objeto
                        results[0].forEach(function(question){
                            question.tags = [];
                            question.date = moment(question.date).format('YYYY-MM-DD HH:mm:ss');
                            if(question.body.length > 150){
                                question.body = question.body.slice(0, 150) + '...';
                            }
                            questions[question.ID] = question;
                        });
                        results[1].forEach(function(tag){
                            if(questions[tag.question]){
                                questions[tag.question].tags.push(tag.tagName);
                            }
                        });
                        
                        // Formateamos la salida
                        for (const [ k, v ] of Object.entries(questions)) {
                            response.push(v);
                        }
                        
                        callback(false, { totalQuestions: response.length, questions: DAOQuestions.orderQuestions(response) });
                    }
                });
            }
        });
    }

    scoreAnswer(params, callback){
        this.pool.getConnection(function(error, connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            } else{
                connection.query("SELECT COUNT(*) as filas FROM answers_score a WHERE a.IdAnswer =? AND a.user=?", [ params.answer, params.currentUser ], function(error, results){
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    } else{
                        let sql = '', queryParams = [];
                        if(results[0].filas === 0){ // insertar
                            sql = "INSERT INTO answers_score(IdAnswer,user,type) VALUES(?,?,?);";
                            queryParams.push(params.answer, params.currentUser, params.type);
                            connection.query(sql, queryParams, function(error, results){
                                connection.release();
                                if(error){
                                    callback(new Error("Error de acceso a la base de datos"));
                                } else{
                                    callback(null);
                                }
                            });
                        } else{
                            connection.release();
                            callback(null);
                        }
                    }
                });
            }
        });
    }
    
}

module.exports = DAOQuestions;