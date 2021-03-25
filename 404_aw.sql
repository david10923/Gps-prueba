-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-01-2021 a las 17:52:17
-- Versión del servidor: 10.4.16-MariaDB
-- Versión de PHP: 7.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `404_aw`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `answers`
--

CREATE TABLE `answers` (
  `ID` int(11) NOT NULL,
  `user` varchar(100) NOT NULL,
  `question` int(11) NOT NULL,
  `body` varchar(3000) NOT NULL,
  `nLikes` int(11) NOT NULL DEFAULT 0,
  `nDislikes` int(11) NOT NULL DEFAULT 0,
  `date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `answers`
--

INSERT INTO `answers` (`ID`, `user`, `question`, `body`, `nLikes`, `nDislikes`, `date`) VALUES
(1, 'lucas@404.es', 1, 'La propiedad position sirve para posicionar un elemento dentro de la página. Sin embargo, dependiendo de cual sea la propiedad que usemos, el elemento tomará una referencia u otra para posicionarse respecto a ella.\r\n\r\nLos posibles valores que puede adoptar la propiedad position son: static | relative | absolute | fixed | inherit | initial.\r\n', 0, 0, '2021-01-13 20:18:07'),
(2, 'emy@404.es', 2, 'La pseudoclase :nth-child() selecciona los hermanos que cumplan cierta condición definida en la fórmula an + b. a y b deben ser números enteros, n es un contador. El grupo an representa un ciclo, cada cuantos elementos se repite; b indica desde donde empezamos a contar.', 0, 0, '2021-01-13 20:19:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `answers_score`
--

CREATE TABLE `answers_score` (
  `IdAnswer` int(11) NOT NULL,
  `user` varchar(100) NOT NULL,
  `type` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Disparadores `answers_score`
--
DELIMITER $$
CREATE TRIGGER `UpdateAnswers` AFTER UPDATE ON `answers_score` FOR EACH ROW BEGIN
	DECLARE userOrigin varchar(100);
    DECLARE questionOrigin varchar(100);
    
    SELECT a.question INTO questionOrigin
    FROM answers a
    WHERE a.ID = NEW.IdAnswer;
    
    SELECT q.user INTO userOrigin
    FROM questions q
    WHERE q.ID=questionOrigin;
    
IF OLD.TYPE <> NEW.type THEN
	IF NEW.type = 1 THEN
            UPDATE answers
            SET answers.nLikes = answers.nLikes+1,answers.nDislikes=answers.nDislikes-1
            WHERE answers.ID = NEW.IdAnswer;           
          
           -- Para actualizar las medallas de los likes
            IF (SELECT answers.nLikes
            	FROM answers
          		WHERE answers.ID = NEW.IdAnswer)=2 THEN 
                	INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Respuesta interesante");
            ELSEIF (SELECT answers.nLikes
            		FROM answers
          			WHERE answers.ID = NEW.IdAnswer)=4 THEN 
                INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin,"Silver","Buena respuesta");
            ELSEIF (SELECT answers.nLikes
            		FROM answers
          			WHERE answers.ID = NEW.IdAnswer)=6 THEN 
                INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin,"Gold","Excelente respuesta");
           END IF;
                      

           IF (SELECT users.TotalScore
                FROM users
                WHERE users.email = userOrigin)<>1 THEN  

                UPDATE users
                SET users.TotalScore = users.TotalScore+12
                WHERE users.email = userOrigin;
           ELSE 
                UPDATE users
                SET users.TotalScore = users.TotalScore+10
                WHERE users.email = userOrigin;
           END IF;
	ELSE 
        	 -- Quitar las medallas si es necesario
            /*IF(SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question) =1 THEN 
            	 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Bronze" AND
                 medals_user.MedalName = "Estudiante";
                 
             ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=2 THEN 
               DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Bronze" AND
                 medals_user.MedalName = "Pregunta Interesante";
            ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=4 THEN 
                 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Silver" AND
                 medals_user.MedalName = "Buena pregunta";
            ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=6 THEN 
                 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Gold" AND
                 medals_user.MedalName = "Excelente pregunta";
           END IF;*/
    
            UPDATE answers
            SET answers.nDislikes=answers.nDislikes+1,
            answers.nLikes= answers.nLikes-1
            WHERE answers.ID = NEW.IdAnswer; 
            
            UPDATE users
            SET users.TotalScore = users.TotalScore-12
            WHERE users.email = userOrigin;
  	END IF;
    
        IF (SELECT users.TotalScore
            FROM users
            WHERE users.email = userOrigin) <1 THEN

             UPDATE users
             SET users.TotalScore =1
             WHERE users.email = userOrigin;
        END IF;
        
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateAnswersScoreInsert` AFTER INSERT ON `answers_score` FOR EACH ROW BEGIN
	DECLARE userOrigin varchar(100);

    SELECT a.user INTO userOrigin
    FROM answers a
    WHERE a.ID=NEW.IdAnswer;

    -- Sumamos like o dislike a la respuesta
    IF NEW.type = 1 THEN
        UPDATE answers
        SET answers.nLikes = answers.nLikes+1
        WHERE answers.ID = NEW.IdAnswer;
            
        UPDATE users
        SET users.TotalScore = users.TotalScore +10
        WHERE users.email = userOrigin;
    ELSE 
        UPDATE answers
        SET answers.nDislikes=answers.nDislikes+1
        WHERE answers.ID = NEW.IdAnswer;
        
        UPDATE users
        SET users.TotalScore = users.TotalScore-2
        WHERE users.email = userOrigin;
    END IF;

    IF NEW.Type = 1 THEN 
        -- Ortorgamos las medallas correspondientes
        IF (SELECT answers.nLikes
            FROM answers
            WHERE answers.ID = NEW.IdAnswer) = 2 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Respuesta interesante");

        ELSEIF (SELECT answers.nLikes
            FROM answers
            WHERE answers.ID = NEW.IdAnswer) = 4 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin,"Silver","Buena respuesta");

        ELSEIF (SELECT answers.nLikes
            FROM answers
            WHERE answers.ID = NEW.IdAnswer) = 6 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin,"Gold","Excelente respuesta");

        END IF;
    END IF;

    -- Si reputacion negativa entonces igualar a 1
    IF (SELECT users.TotalScore
        FROM users
        WHERE users.email = userOrigin) <1 THEN
          UPDATE users
          SET users.TotalScore =1
          WHERE users.email = userOrigin;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medals_user`
--

CREATE TABLE `medals_user` (
  `IdUser` varchar(100) NOT NULL,
  `MedalType` enum('Gold','Silver','Bronze') NOT NULL,
  `MedalName` varchar(100) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `questions`
--

CREATE TABLE `questions` (
  `ID` int(11) NOT NULL,
  `user` varchar(100) NOT NULL,
  `title` varchar(1000) NOT NULL,
  `body` varchar(3000) NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `visits` int(11) NOT NULL DEFAULT 0,
  `nLikes` int(11) NOT NULL DEFAULT 0,
  `nDislikes` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `questions`
--

INSERT INTO `questions` (`ID`, `user`, `title`, `body`, `date`, `visits`, `nLikes`, `nDislikes`) VALUES
(1, 'nico@404.es', '¿Cual es la diferencia entre position: relative, position: absolute y position: fixed?', 'Sé que estas propiedades de CSS sirven para posicionar un elemento dentro de la página. Sé que estas propiedades de CSS sirven para posicionar un elemento dentro de la página.', '2021-01-13 20:11:05', 0, 0, 0),
(2, 'roberto@404.es', '¿Cómo funciona exactamente nth-child?', 'No acabo de comprender muy bien que hace exactamente y qué usos prácticos puede tener.', '2021-01-13 20:18:42', 0, 0, 0),
(3, 'sfg@404.es', 'Diferencias entre == y === (comparaciones en JavaScript)', 'Siempre he visto que en JavaScript hay:\r\n\r\nasignaciones =\r\ncomparaciones == y ===\r\nCreo entender que == hace algo parecido a comparar el valor de la variable y el === también compara el tipo (como un equals de java).\r\n', '2021-01-13 20:20:07', 0, 0, 0),
(4, 'marta@404.es', 'Problema con asincronismo en Node', 'Soy nueva en Node... Tengo una modulo que conecta a una BD de postgres por medio de pg-node. En eso no tengo problemas. Mi problema es que al llamar a ese modulo, desde otro modulo, y despues querer usar los datos que salieron de la BD me dice undefined... Estoy casi seguro que es porque la conexion a la BD devuelve una promesa, y los datos no estan disponibles al momento de usarlos.', '2021-01-13 20:21:00', 0, 0, 0),
(5, 'lucas@404.es', '¿Qué es la inyección SQL y cómo puedo evitarla?', 'He encontrado bastantes preguntas en StackOverflow sobre programas o formularios web que guardan información en una base de datos (especialmente en PHP y MySQL) y que contienen graves problemas de seguridad relacionados principalmente con la inyección SQL.\r\n\r\nNormalmente dejo un comentario y/o un enlace a una referencia externa, pero un comentario no da mucho espacio para mucho y sería positivo que hubiera una referencia interna en SOes sobre el tema así que decidí escribir esta pregunta.\r\n', '2021-01-13 20:21:40', 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `questions_score`
--

CREATE TABLE `questions_score` (
  `question` int(11) NOT NULL,
  `user` varchar(100) NOT NULL,
  `type` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Disparadores `questions_score`
--
DELIMITER $$
CREATE TRIGGER `updateQuestionScoreInsert` AFTER INSERT ON `questions_score` FOR EACH ROW BEGIN
	DECLARE userOrigin varchar(100);
    
    SELECT q.user INTO userOrigin
    FROM questions q
    WHERE q.ID = NEW.question;
    
    -- Sumar voto (like/dislike)
    IF NEW.Type = 1 THEN 
        UPDATE questions
        SET questions.nLikes = questions.nLikes+1
        WHERE questions.id = NEW.question;

        UPDATE users
        SET users.TotalScore = users.TotalScore +10
        WHERE users.email = userOrigin;
    ELSE
        UPDATE questions
        SET questions.nDislikes=questions.nDislikes+1
        WHERE questions.id = NEW.question;

        UPDATE users
        SET users.TotalScore = users.TotalScore-2
        WHERE users.email = userOrigin;
    END IF;

    IF NEW.Type = 1 THEN 
        -- Como estamos en questions_score, ver el numero de likes que tiene para otorgar medallas
        IF (SELECT questions.nLikes
            FROM questions
            WHERE questions.ID = NEW.question) = 1 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Estudiante");

        ELSEIF (SELECT questions.nLikes
            FROM questions
            WHERE questions.ID = NEW.question) = 2 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Pregunta interesante");

        ELSEIF (SELECT questions.nLikes
            FROM questions
            WHERE questions.ID = NEW.question) = 4 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Silver","Buena pregunta");

        ELSEIF (SELECT questions.nLikes
            FROM questions
            WHERE questions.ID = NEW.question) = 6 THEN
            INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Gold","Excelente pregunta");
        END IF;
    END IF;

    -- Si reputacion negativa ponerle 1
    IF (SELECT users.TotalScore
        FROM users
        WHERE users.email = userOrigin) <1 THEN
			UPDATE users
			SET users.TotalScore =1
			WHERE users.email = userOrigin;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateQuestions` AFTER UPDATE ON `questions_score` FOR EACH ROW BEGIN
	DECLARE userOrigin varchar(100);
    
    SELECT q.user INTO userOrigin
    FROM questions q
    WHERE q.ID=NEW.question;
    
	IF OLD.TYPE <> NEW.type THEN
		IF NEW.type = 1 THEN
			UPDATE questions
			SET questions.nLikes=questions.nLikes+1,             questions.nDislikes=questions.nDislikes-1
            WHERE questions.id = NEW.question;           
          
			-- Para actualizar las medallas de los likes
			IF(SELECT questions.nLikes
            	FROM questions
          		WHERE questions.ID = NEW.question)=1 THEN 
				INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Estudiante");
			ELSEIF (SELECT questions.nLikes
            		FROM questions
          			WHERE questions.ID = NEW.question)=2 THEN 
                INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Bronze","Pregunta interesante");
            ELSEIF (SELECT questions.nLikes
            		FROM questions
          			WHERE questions.ID = NEW.question)=4 THEN 
                INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Silver","Buena pregunta");
            ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=6 THEN  
                INSERT INTO medals_user(IdUser, MedalType, MedalName) VALUES(userOrigin ,"Gold","Excelente pregunta");
           END IF;
                      

			IF (SELECT users.TotalScore
                FROM users
                WHERE users.email = NEW.user)<>1 THEN
				UPDATE users
                SET users.TotalScore = users.TotalScore+12
                WHERE users.email = userOrigin;
           ELSE 
                UPDATE users
                SET users.TotalScore = users.TotalScore+10
                WHERE users.email = userOrigin;
           END IF;
	ELSE 
    	
        	 -- Quitar las medallas si es necesario
            
            /*IF(SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question) =1 THEN 
            	 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Bronze" AND
                 medals_user.MedalName = "Estudiante";
                 
             ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=2 THEN 
               DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Bronze" AND
                 medals_user.MedalName = "Pregunta Interesante";
            ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=4 THEN 
                 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Silver" AND
                 medals_user.MedalName = "Buena pregunta";
            ELSEIF (SELECT questions.nLikes
            FROM questions
          	WHERE questions.ID = NEW.question)=6 THEN 
                 DELETE FROM `medals_user`
                 WHERE medals_user.IdUser= NEW.user AND 
                 medals_user.MedalType = "Gold" AND
                 medals_user.MedalName = "Excelente pregunta";
           END IF;*/
    
            UPDATE questions
            SET questions.nDislikes=questions.nDislikes+1,
            questions.nLikes= questions.nLikes-1
            WHERE questions.id = NEW.question; 
            
            UPDATE users
            SET users.TotalScore = users.TotalScore-12
            WHERE users.email = userOrigin;
  	END IF;
    
        IF (SELECT users.TotalScore
            FROM users
            WHERE users.email = userOrigin) <1 THEN

             UPDATE users
             SET users.TotalScore =1
             WHERE users.email = userOrigin;
        END IF;
        
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) UNSIGNED NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tags`
--

CREATE TABLE `tags` (
  `question` int(11) NOT NULL,
  `tagName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tags`
--

INSERT INTO `tags` (`question`, `tagName`) VALUES
(1, 'css'),
(1, 'css3'),
(2, 'css'),
(2, 'html'),
(3, 'JavaScript'),
(4, 'nodejs'),
(5, 'mysql'),
(5, 'sql');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `profileImg` varchar(200) NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `TotalScore` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `email`, `username`, `password`, `profileImg`, `date`, `TotalScore`) VALUES
(1, 'nico@404.es', 'Nico', '1234', 'f800e51a263d98490833b119974d2188', '2021-01-13 20:06:50', 1),
(2, 'roberto@404.es', 'Roberto', '1234', 'b76c7bd454bfc05b903df95608189351', '2021-01-13 20:07:39', 1),
(3, 'sfg@404.es', 'SFG', '1234', '46b1317c4f6553d2d881de96226542fb', '2021-01-13 20:08:07', 1),
(4, 'marta@404.es', 'Marta', '1234', 'b7218850ecebaa3bd3033fdfd58326cb', '2021-01-13 20:08:34', 1),
(5, 'lucas@404.es', 'Lucas', '1234', 'default', '2021-01-13 20:08:56', 1),
(6, 'emy@404.es', 'Emy', '1234', 'fbb25d800da04a43f9dde9d54f053337', '2021-01-13 20:09:30', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `visits`
--

CREATE TABLE `visits` (
  `question` int(11) NOT NULL,
  `user` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Disparadores `visits`
--
DELIMITER $$
CREATE TRIGGER `totalVisits` AFTER INSERT ON `visits` FOR EACH ROW BEGIN 
    DECLARE userOrigin varchar(100);    
    
    SELECT q.user INTO userOrigin
    FROM questions q
    WHERE q.ID=NEW.question;

    UPDATE questions
    SET questions.visits=questions.visits + 1
    WHERE questions.ID = NEW.question;

     -- Para actualizar las medallas de las visitas

          IF(SELECT questions.visits
            FROM questions
              WHERE questions.ID = NEW.question) =2 THEN 
                  INSERT INTO medals_user(IdUser,MedalType, MedalName) VALUES(userOrigin ,"Bronze","Pregunta Popular");
             ELSEIF (SELECT questions.visits
            FROM questions
              WHERE questions.ID = NEW.question)=4 THEN 
                INSERT INTO medals_user(IdUser,MedalType, MedalName) VALUES(userOrigin ,"Silver","Pregunta Destacada");
            ELSEIF (SELECT questions.visits
            FROM questions
              WHERE questions.ID = NEW.question)=6 THEN 
                INSERT INTO medals_user(IdUser,MedalType, MedalName) VALUES(userOrigin ,"Gold","Pregunta famosa");
           END IF;

END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `user` (`user`),
  ADD KEY `question` (`question`);

--
-- Indices de la tabla `answers_score`
--
ALTER TABLE `answers_score`
  ADD PRIMARY KEY (`IdAnswer`,`user`),
  ADD KEY `user` (`user`);

--
-- Indices de la tabla `medals_user`
--
ALTER TABLE `medals_user`
  ADD KEY `IdUser` (`IdUser`);

--
-- Indices de la tabla `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `user` (`user`);

--
-- Indices de la tabla `questions_score`
--
ALTER TABLE `questions_score`
  ADD PRIMARY KEY (`question`,`user`) USING BTREE,
  ADD KEY `user` (`user`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Indices de la tabla `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`question`,`tagName`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email_pk` (`email`) USING BTREE;

--
-- Indices de la tabla `visits`
--
ALTER TABLE `visits`
  ADD PRIMARY KEY (`question`,`user`),
  ADD KEY `user` (`user`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `answers`
--
ALTER TABLE `answers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `questions`
--
ALTER TABLE `questions`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `answers`
--
ALTER TABLE `answers`
  ADD CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`email`),
  ADD CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`question`) REFERENCES `questions` (`ID`);

--
-- Filtros para la tabla `answers_score`
--
ALTER TABLE `answers_score`
  ADD CONSTRAINT `answers_score_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`email`),
  ADD CONSTRAINT `answers_score_ibfk_2` FOREIGN KEY (`IdAnswer`) REFERENCES `answers` (`ID`);

--
-- Filtros para la tabla `medals_user`
--
ALTER TABLE `medals_user`
  ADD CONSTRAINT `medals_user_ibfk_1` FOREIGN KEY (`IdUser`) REFERENCES `users` (`email`),
  ADD CONSTRAINT `medals_user_ibfk_2` FOREIGN KEY (`IdUser`) REFERENCES `users` (`email`);

--
-- Filtros para la tabla `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`email`);

--
-- Filtros para la tabla `questions_score`
--
ALTER TABLE `questions_score`
  ADD CONSTRAINT `questions_score_ibfk_1` FOREIGN KEY (`question`) REFERENCES `questions` (`ID`),
  ADD CONSTRAINT `questions_score_ibfk_2` FOREIGN KEY (`user`) REFERENCES `users` (`email`);

--
-- Filtros para la tabla `tags`
--
ALTER TABLE `tags`
  ADD CONSTRAINT `tags_ibfk_1` FOREIGN KEY (`question`) REFERENCES `questions` (`ID`);

--
-- Filtros para la tabla `visits`
--
ALTER TABLE `visits`
  ADD CONSTRAINT `visits_ibfk_1` FOREIGN KEY (`question`) REFERENCES `questions` (`ID`),
  ADD CONSTRAINT `visits_ibfk_2` FOREIGN KEY (`user`) REFERENCES `users` (`email`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
