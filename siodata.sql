-- TABELLA 'utenti'
CREATE TABLE utenti
(
	id_utenti INT CONSTRAINT utenti_pk PRIMARY KEY,
	cognome_utenti VARCHAR2(250) NOT NULL,
	nome_utenti VARCHAR2(250) NOT NULL,
	data_nascita_utenti DATE NOT NULL,
	cf_utenti CHAR(16) NOT NULL,
	username_utenti VARCHAR2(20),
  pw_utenti VARCHAR2(20)
);

-- TABELLA DI BACKUP 'utenti_bkp'

CREATE TABLE utenti_bkp
(
	id_bkp INT CONSTRAINT utenti_bkp_pk PRIMARY KEY,
	data_bkp TIMESTAMP NOT NULL,
	dml_bkp CHAR(1),
	id_utenti INT,
	old_cogn_utenti VARCHAR2(250),
	cognome_utenti VARCHAR2(250),
	old_nome_utenti VARCHAR2(250), 
	nome_utenti VARCHAR2(250),
	old_dnas_utenti DATE,
	data_nascita_utenti DATE,
	old_cf_utenti CHAR(16),
	cf_utenti CHAR(16),
	old_usern_utenti VARCHAR2(20),
	username_utenti VARCHAR2(20),
	old_pw_utenti VARCHAR2(20),
  pw_utenti VARCHAR2(20)
);

-- TRIGGER
-- CON QUESTO TRIGGER TENGO TRACCIA DELLE OPERAZIONI DML E DEI CAMBIAMENTI SUI DATI (IN CASO DI UPDATING) INSERENDOLI NELLA TABELLA 
-- DI BACK UP utenti_bkp

CREATE OR REPLACE TRIGGER tr_cmp_utenti_bkp
FOR INSERT OR UPDATE OR DELETE
ON utenti
COMPOUND TRIGGER 
	l_dml_bkp utenti_bkp.dml_bkp%TYPE;
	l_old_cogn_utenti utenti.cognome_utenti%TYPE;
	l_old_nome_utenti utenti.nome_utenti%TYPE;
	l_old_dnas_utenti utenti.data_nascita_utenti%TYPE;
	l_old_cf_utenti utenti.cf_utenti%TYPE;
	l_old_usern_utenti utenti.username_utenti%TYPE;
	l_old_pw_utenti utenti.pw_utenti%TYPE;
BEFORE EACH ROW IS
	BEGIN
		IF DELETING THEN
			l_dml_bkp := 'D';
			DBMS_OUTPUT.PUT_LINE('Cancellazione ...');
			INSERT INTO utenti_bkp(id_bkp, data_bkp, dml_bkp, id_utenti, cognome_utenti, nome_utenti, data_nascita_utenti, cf_utenti, username_utenti, pw_utenti) 
			VALUES(pkg_utenti_mgmt.fnc_set_id_bkp(), SYSDATE, l_dml_bkp, :OLD.id_utenti, :OLD.cognome_utenti, :OLD.nome_utenti, :OLD.data_nascita_utenti, 
			:OLD.cf_utenti, :OLD.username_utenti, :OLD.pw_utenti);
		END IF;
	END BEFORE EACH ROW;
AFTER EACH ROW IS
	BEGIN
		IF INSERTING THEN
			DBMS_OUTPUT.PUT_LINE('Inserimento ...');
			l_dml_bkp := 'I';
			INSERT INTO utenti_bkp(id_bkp, data_bkp, dml_bkp, id_utenti, cognome_utenti, nome_utenti, data_nascita_utenti, cf_utenti, username_utenti, pw_utenti) 
			VALUES(pkg_utenti_mgmt.fnc_set_id_bkp(), SYSDATE, l_dml_bkp, :NEW.id_utenti, :NEW.cognome_utenti, :NEW.nome_utenti, :NEW.data_nascita_utenti, 
				:NEW.cf_utenti, :NEW.username_utenti, :NEW.pw_utenti);
		END IF;
		IF UPDATING THEN
			DBMS_OUTPUT.PUT_LINE('Aggiornamento ...');
			l_dml_bkp := 'U';
			IF :NEW.cognome_utenti != :OLD.cognome_utenti THEN
				l_old_cogn_utenti := :OLD.cognome_utenti;
			END IF;
			IF :NEW.nome_utenti != :OLD.nome_utenti THEN
				l_old_nome_utenti := :OLD.nome_utenti;
			END IF;
			IF :NEW.data_nascita_utenti != :OLD.data_nascita_utenti THEN
				l_old_dnas_utenti := :OLD.data_nascita_utenti;
			END IF;
			IF :NEW.cf_utenti != :OLD.cf_utenti THEN
				l_old_cf_utenti := :OLD.cf_utenti;
			END IF;
			IF :NEW.username_utenti != :OLD.username_utenti THEN
				l_old_usern_utenti := :OLD.username_utenti;
			END IF;
			IF :NEW.pw_utenti != :OLD.pw_utenti THEN
				l_old_pw_utenti := :OLD.pw_utenti;
			END IF;
			INSERT INTO utenti_bkp(id_bkp, data_bkp, dml_bkp, id_utenti, old_cogn_utenti, cognome_utenti, old_nome_utenti, nome_utenti, old_dnas_utenti, 
				data_nascita_utenti, old_cf_utenti, cf_utenti, old_usern_utenti, username_utenti, old_pw_utenti, pw_utenti) 
			VALUES(pkg_utenti_mgmt.fnc_set_id_bkp(), SYSDATE, l_dml_bkp, :NEW.id_utenti, l_old_cogn_utenti, :NEW.cognome_utenti, l_old_nome_utenti, :NEW.nome_utenti, 
				l_old_dnas_utenti, :NEW.data_nascita_utenti, l_old_cf_utenti, :NEW.cf_utenti, l_old_usern_utenti, :NEW.username_utenti, l_old_pw_utenti, 
				:NEW.pw_utenti);
		END IF;
	END AFTER EACH ROW;
END tr_cmp_utenti_bkp;


CREATE OR REPLACE PACKAGE pkg_utenti_mgmt AS

	g_count INT;
	
	TYPE utente_aa IS TABLE OF utenti%ROWTYPE INDEX BY BINARY_INTEGER;
	g_utente_aa utente_aa;
	
	PROCEDURE pcd_inserisci(p_cognome utenti.cognome_utenti%TYPE, p_nome utenti.nome_utenti%TYPE, p_data_n utenti.data_nascita_utenti%TYPE, 
		p_cf utenti.cf_utenti%TYPE, p_usern utenti.username_utenti%TYPE, p_pw utenti.pw_utenti%TYPE, p_out OUT INT);
	
	PROCEDURE pcd_aggiorna(p_id utenti.id_utenti%TYPE, p_cognome utenti.cognome_utenti%TYPE, p_nome utenti.nome_utenti%TYPE, 
		p_data_n utenti.data_nascita_utenti%TYPE, p_cf utenti.cf_utenti%TYPE, p_usern utenti.username_utenti%TYPE, p_pw utenti.pw_utenti%TYPE, p_out OUT INT);
		
	PROCEDURE pcd_elimina(p_id utenti.id_utenti%TYPE, p_out OUT INT);
		
	PROCEDURE pcd_genera_id(p_out OUT INT);
	
	PROCEDURE pcd_trova_utente_login(p_usern utenti.username_utenti%TYPE, p_pw utenti.pw_utenti%TYPE, p_out OUT INT);
	
	FUNCTION fnc_set_id RETURN utenti.id_utenti%TYPE;
	
	FUNCTION fnc_set_id_bkp RETURN utenti_bkp.id_bkp%TYPE;
	
	PROCEDURE pcd_get_selected(p_id utenti.id_utenti%TYPE, p_out_id OUT INT, p_out_cogn OUT VARCHAR2, p_out_nome OUT VARCHAR2, p_out_datanas OUT CHAR, 
		p_out_cf OUT CHAR, p_out_usern OUT VARCHAR2, p_out_pw OUT VARCHAR2); 
	
END pkg_utenti_mgmt;


CREATE OR REPLACE PACKAGE BODY pkg_utenti_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cognome utenti.cognome_utenti%TYPE, 
		p_nome utenti.nome_utenti%TYPE, 
		p_data_n utenti.data_nascita_utenti%TYPE, 
		p_cf utenti.cf_utenti%TYPE, 
		p_usern utenti.username_utenti%TYPE, 
		p_pw utenti.pw_utenti%TYPE, 
		p_out OUT INT)AS
	BEGIN
		SELECT COUNT(id_utenti) INTO g_count 
			FROM utenti
		WHERE cf_utenti = UPPER(p_cf) AND username_utenti = p_usern;
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('CODICE FISCALE <' || UPPER(p_cf) || '> già presente.');
			DBMS_OUTPUT.PUT_LINE('USERNAME <' || p_usern || '> già presente.');		
			RETURN;
		ELSE
			SELECT COUNT(id_utenti) INTO g_count 
				FROM utenti
			WHERE cf_utenti = UPPER(p_cf);
			IF g_count > 0 THEN
				DBMS_OUTPUT.PUT_LINE('CODICE FISCALE <' || UPPER(p_cf) || '> già presente.');
				RETURN;
			ELSE
				SELECT COUNT(id_utenti) INTO g_count 
					FROM utenti
				WHERE username_utenti = p_usern;
				IF g_count > 0 THEN
					DBMS_OUTPUT.PUT_LINE('USERNAME <' || p_usern || '> già presente.');
					RETURN;
				END IF;
			END IF;
		END IF;
		INSERT INTO utenti(id_utenti, cognome_utenti, nome_utenti, data_nascita_utenti, cf_utenti, username_utenti, pw_utenti) 
		VALUES(fnc_set_id(), UPPER(p_cognome), UPPER(p_nome), p_data_n, UPPER(p_cf), p_usern, p_pw);   -- vvvvv
		COMMIT;
		p_out := 1;
		DBMS_OUTPUT.PUT_LINE('Utente inserito.');
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_inserisci;
	
	PROCEDURE pcd_aggiorna(
		p_id utenti.id_utenti%TYPE, 
		p_cognome utenti.cognome_utenti%TYPE, 
		p_nome utenti.nome_utenti%TYPE, 
		p_data_n utenti.data_nascita_utenti%TYPE, 
		p_cf utenti.cf_utenti%TYPE, 
		p_usern utenti.username_utenti%TYPE, 
		p_pw utenti.pw_utenti%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(id_utenti) INTO g_count
			FROM utenti
		WHERE id_utenti = p_id;
		IF g_count > 0 THEN
			UPDATE utenti SET cognome_utenti = UPPER(p_cognome), nome_utenti = UPPER(p_nome), data_nascita_utenti = p_data_n, cf_utenti = UPPER(p_cf), 
				username_utenti = p_usern, pw_utenti = p_pw WHERE id_utenti = p_id;
			SELECT COUNT(id_utenti) INTO g_count 
				FROM utenti 
			WHERE cf_utenti = UPPER(p_cf) AND username_utenti = p_usern;
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('Utente con CODICE FISCALE <' || UPPER(p_cf) || '> e USERNAME <' || p_usern || '> già nel database. Non aggiornato.');
				ROLLBACK;
			ELSE 
				SELECT COUNT(id_utenti) INTO g_count 
					FROM utenti 
				WHERE cf_utenti = UPPER(p_cf);
				IF g_count > 1 THEN
					DBMS_OUTPUT.PUT_LINE('Utente con CODICE FISCALE <' || UPPER(p_cf) || '> già nel database. Non aggiornato.');
					ROLLBACK;
				ELSE 
					SELECT COUNT(id_utenti) INTO g_count 
						FROM utenti 
					WHERE username_utenti = p_usern;
					IF g_count > 1 THEN
						DBMS_OUTPUT.PUT_LINE('Utente con USERNAME <' || p_usern || '> già nel database. Non aggiornato.');
						ROLLBACK;
					ELSE
						COMMIT;
						p_out := 1;
						DBMS_OUTPUT.PUT_LINE('Utente con CF <' || p_cf || '> aggiornato.');
					END IF;
				END IF;
			END IF;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Utente non trovato. Riprovare.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_id utenti.id_utenti%TYPE,
		p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(id_utenti) INTO g_count
			FROM utenti
		WHERE id_utenti = p_id;
		IF g_count > 0 THEN
			DELETE FROM utenti 
				WHERE id_utenti = p_id;
			COMMIT;
			p_out := 1;
			DBMS_OUTPUT.PUT_LINE('Utente eliminato.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('Utente non trovato.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;
	
	PROCEDURE pcd_genera_id(
		p_out OUT INT
	)IS
	BEGIN
		SELECT MAX(id_utenti) + 1 INTO g_count FROM utenti;
		IF g_count IS NULL THEN
			g_count := 600001;
		END IF;
		p_out := g_count;
		dbms_output.put_line(p_out);
	END pcd_genera_id;
	
	PROCEDURE pcd_trova_utente_login(
		p_usern utenti.username_utenti%TYPE, 
		p_pw utenti.pw_utenti%TYPE, 
		p_out OUT INT
	) AS
	BEGIN
		SELECT COUNT(id_utenti) INTO g_count     
			FROM utenti 
		WHERE
      username_utenti = p_usern AND pw_utenti = p_pw;
		IF g_count > 0 THEN
			p_out := 1;
		ELSE
			RETURN;
		END IF;
	END pcd_trova_utente_login;
	
	FUNCTION fnc_set_id RETURN utenti.id_utenti%TYPE AS
	BEGIN
		SELECT MAX(id_utenti) + 1 INTO g_count 
			FROM utenti;
		IF g_count IS NULL THEN
			g_count := 600001;
		END IF;
		RETURN g_count;
	END fnc_set_id;

	FUNCTION fnc_set_id_bkp RETURN utenti_bkp.id_bkp%TYPE AS
	BEGIN
		SELECT MAX(id_bkp) + 1 INTO g_count 
			FROM utenti_bkp;
		IF g_count IS NULL THEN
			g_count := 9000001;
		END IF;
		RETURN g_count;
	END fnc_set_id_bkp;
	
	PROCEDURE pcd_get_selected(
		p_id utenti.id_utenti%TYPE, 
		p_out_id OUT INT, 
		p_out_cogn OUT VARCHAR2, 
		p_out_nome OUT VARCHAR2, 
		p_out_datanas OUT CHAR,
		p_out_cf OUT CHAR, 
		p_out_usern OUT VARCHAR2, 
		p_out_pw OUT VARCHAR2
	)AS
	BEGIN
		SELECT utenti.* BULK COLLECT INTO g_utente_aa -- vedere bulk collect (necessario)
			FROM utenti 
		WHERE id_utenti = p_id;
		FOR i IN g_utente_aa.FIRST .. g_utente_aa.LAST LOOP
			p_out_id := g_utente_aa(i).id_utenti;
			p_out_cogn := g_utente_aa(i).cognome_utenti;
			p_out_nome := g_utente_aa(i).nome_utenti;
			p_out_datanas := TO_CHAR(g_utente_aa(i).data_nascita_utenti, 'DD/MM/YYYY');
			p_out_cf := g_utente_aa(i).cf_utenti;
			p_out_usern := g_utente_aa(i).username_utenti;
			p_out_pw := g_utente_aa(i).pw_utenti;
			DBMS_OUTPUT.PUT_LINE(p_out_id);
			DBMS_OUTPUT.PUT_LINE(p_out_cogn);
			DBMS_OUTPUT.PUT_LINE(p_out_nome);
			DBMS_OUTPUT.PUT_LINE(p_out_datanas);
			DBMS_OUTPUT.PUT_LINE(p_out_cf);
			DBMS_OUTPUT.PUT_LINE(p_out_usern);
			DBMS_OUTPUT.PUT_LINE(p_out_pw);
		END LOOP;
	END pcd_get_selected;
	
END pkg_utenti_mgmt; 

-- 	TEST PACKAGE 'pkg_utenti_mgmt'
	
	-- pkg_utenti_mgmt.pcd_inserisci
	
		-- inserisco un utente -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_inserisci('rossi', 'mario', '01-feb-2000', 'cfrossimario', 'rossi', '123456', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		--lo inserisco di nuovo e deve dare 2 mess errore (cf, usern) -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_inserisci('rossi', 'mario', '01-feb-2000', 'cfrossimario', 'rossi', '123456', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- inserisco utente con stesso CF  e da errore -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_inserisci('rossi', 'mario', '01-feb-2000', 'cfrossimario', 'rossi2', '123456', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- inserisco utente con stesso username  e da errore -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_inserisci('rossi', 'mario', '01-feb-2000', 'cfrossimario2', 'rossi', '123456', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- inserisco il secondo utente
		
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_inserisci('bianchi', 'sergio', '02-gen-2000', 'cfbianchisergio', 'bianchi', '654321', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
	-- pkg_utenti_mgmt.pcd_aggiorna
		
		-- aggiorno 'mario rossi' con cf e usern di 'bianchi sergio': errore su CF e usern -- OK
		DECLARE
				l_out INT;
		BEGIN
				pkg_utenti_mgmt.pcd_aggiorna(600001, 'rossi', 'mario', '01-feb-2000', 'cfbianchisergio', 'bianchi', '01022000', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;   
		
		-- aggiorno 'mario rossi' con cf di 'bianchi sergio': errore su CF  -- OK
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_aggiorna(600001, 'rossi', 'mario', '01-feb-2000', 'cfbianchisergio', 'sql', '01022000', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- aggiorno 'mario rossi' con usern di 'bianchi sergio': errore su usern  -- OK
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_aggiorna(600001, 'rossi', 'mario', '01-feb-2000', 'cfrossimario2', 'bianchi', '01022000', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- aggiorno mario rossi con cf e pw diverse -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_aggiorna(600001, 'rossi', 'mario', '01-feb-2000', 'nuovocf', 'username', '01022000', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
	
	-- -- pkg_utenti_mgmt.pcd_elimina
	
		-- elimino utente -- ok
			DECLARE
			l_out INT;
			BEGIN
				pkg_utenti_mgmt.pcd_elimina(600004, l_out);
				DBMS_OUTPUT.PUT_LINE(l_out);
			END;
			
		-- elimino utente -- non lo trovo
			DECLARE
			l_out INT;
			BEGIN
				pkg_utenti_mgmt.pcd_elimina(600004, l_out);
				DBMS_OUTPUT.PUT_LINE(l_out);
			END;
		
	-- pkg_utenti_mgmt.pcd_trova_utente_login
		
		-- trovo utente -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_trova_utente_login('rossi', '01022000', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- NON trovo utente -- ok
		DECLARE
			l_out INT;
		BEGIN
			pkg_utenti_mgmt.pcd_trova_utente_login('prandi', '01021999', l_out);
			DBMS_OUTPUT.PUT_LINE(l_out);
		END;
		
		-- pkg_utenti_mgmt.pcd_get_selected -- OK
		
		DECLARE
			l_out_id INT;
			l_out_cogn VARCHAR2(250);
			l_out_nome VARCHAR2(250);
			l_out_data 	CHAR;
			l_out_cf CHAR(16);
			l_out_usern VARCHAR2(20);
			l_out_pw VARCHAR2(20);
		BEGIN
			pkg_utenti_mgmt.pcd_get_selected(600001, l_out_id, l_out_cogn, l_out_nome, l_out_data, l_out_cf, l_out_usern, l_out_pw);
		END;


---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


CREATE TABLE osp_liguri 
(
	cod_osp INT CONSTRAINT osp_liguri_fk PRIMARY KEY, -- PK 
	des_osp VARCHAR2(40) NOT NULL,
	dt_ini DATE NOT NULL,
	dt_end DATE,
	dt_cre DATE NOT NULL,
	id_utenti INT CONSTRAINT osp_liguri_utenti_fk REFERENCES utenti(id_utenti),
	dt_mod DATE
);

-- TABELLA DI BACKUP 'osp_liguri_bkp'

CREATE TABLE osp_liguri_bkp
(
	id_bkp INT CONSTRAINT osp_liguri_bkp_fk PRIMARY KEY,
	data_bkp TIMESTAMP NOT NULL,
	dml_bkp CHAR(1),
	old_cod_osp NUMBER, 
	cod_osp number, 
	old_des_osp VARCHAR2(40),
	des_osp VARCHAR2(40),
	dt_ini DATE,
	dt_end DATE,
	dt_cre DATE,
	id_utenti INT,
	dt_mod DATE
);

CREATE OR REPLACE PACKAGE pkg_osp_liguri_mgmt AS
		
	g_count INT; 

	TYPE osp_aa IS TABLE OF osp_liguri%ROWTYPE INDEX BY BINARY_INTEGER;
	g_osp_aa osp_aa;

	TYPE rec_osp IS RECORD(p_cod osp_liguri.cod_osp%TYPE, p_des osp_liguri.des_osp%TYPE);
	g_rec_osp rec_osp;

	PROCEDURE pcd_inserisci(p_cod osp_liguri.cod_osp%TYPE, p_des osp_liguri.des_osp%TYPE, p_dt_ini osp_liguri.dt_ini%TYPE, p_dt_end osp_liguri.dt_end%TYPE, 
		p_dt_cre osp_liguri.dt_cre%TYPE, p_id_utenti osp_liguri.id_utenti%TYPE, p_dt_mod osp_liguri.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_aggiorna(p_cod osp_liguri.cod_osp%TYPE, p_des osp_liguri.des_osp%TYPE, p_dt_ini osp_liguri.dt_ini%TYPE, p_dt_end osp_liguri.dt_end%TYPE, 
		p_dt_cre osp_liguri.dt_cre%TYPE, p_id_utenti osp_liguri.id_utenti%TYPE, p_dt_mod osp_liguri.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_elimina(p_cod osp_liguri.cod_osp%TYPE, p_out OUT INT);

	PROCEDURE pcd_trova_con_descr(p_des osp_liguri.des_osp%TYPE, p_out OUT INT);
	
	PROCEDURE pcd_get_selected(p_cod osp_liguri.cod_osp%TYPE, p_out_cod OUT INT, p_out_des OUT VARCHAR2, p_out_dtini OUT CHAR, p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR, p_out_idutenti OUT INT, p_out_dtmod OUT CHAR);
	
	-- trovo ID in automatico per inserimento dati nella tabella di backup
	FUNCTION fnc_id_bkp RETURN osp_liguri.cod_osp%TYPE;

	FUNCTION fnc_trova_aa(p_des osp_liguri.des_osp%TYPE, p_out OUT INT) RETURN osp_aa;

END pkg_osp_liguri_mgmt;
		

CREATE OR REPLACE PACKAGE BODY pkg_osp_liguri_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cod osp_liguri.cod_osp%TYPE, 
		p_des osp_liguri.des_osp%TYPE, 
		p_dt_ini osp_liguri.dt_ini%TYPE, 
		p_dt_end osp_liguri.dt_end%TYPE, 
		p_dt_cre osp_liguri.dt_cre%TYPE, 
		p_id_utenti osp_liguri.id_utenti%TYPE, 
		p_dt_mod osp_liguri.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count	-- VEDERE VALIDAZIONE PER P_COD E P_DES
		FROM osp_liguri 
		WHERE cod_osp = p_cod AND des_osp = p_des;
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('Codice e descrizione già presenti a db. Errore di inserimento');
		ELSE
			SELECT COUNT(cod_osp) INTO g_count
				FROM osp_liguri 
			WHERE cod_osp = p_cod;
			INSERT INTO osp_liguri(cod_osp, des_osp, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
			VALUES (p_cod, UPPER(p_des), p_dt_ini, p_dt_end, p_dt_cre, p_id_utenti, p_dt_mod);
			COMMIT;
			p_out := 1;
			DBMS_OUTPUT.PUT_LINE('Codice ospedale: ' || p_cod);
			DBMS_OUTPUT.PUT_LINE('Descrizione ospedale: ' || p_des);
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE; -- moved under ROLLBACK
	END pcd_inserisci;
	
	PROCEDURE pcd_aggiorna(
		p_cod osp_liguri.cod_osp%TYPE, 
		p_des osp_liguri.des_osp%TYPE, 
		p_dt_ini osp_liguri.dt_ini%TYPE,
		p_dt_end osp_liguri.dt_end%TYPE, 
		p_dt_cre osp_liguri.dt_cre%TYPE, 
		p_id_utenti osp_liguri.id_utenti%TYPE, 
		p_dt_mod osp_liguri.dt_mod%TYPE,
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count 
			FROM osp_liguri
		WHERE cod_osp = p_cod;
		IF g_count = 1 THEN
			UPDATE osp_liguri 
				SET des_osp = p_des, dt_ini = p_dt_ini, dt_end = p_dt_end, dt_cre = p_dt_cre, id_utenti = p_id_utenti, dt_mod = p_dt_mod     
			WHERE cod_osp = p_cod;
			SELECT COUNT(cod_osp) INTO g_count 
				FROM osp_liguri 
			WHERE des_osp = p_des;
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('OSPEDALE con descrizione ' || p_des || ' già presente. OSPEDALE non aggiornato.');
				ROLLBACK;
			ELSE
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('OSPEDALE con descrizione' || p_des || ' aggiornato.');
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_cod osp_liguri.cod_osp%TYPE,
		p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count 
			FROM osp_liguri 
		WHERE cod_osp = p_cod;
		IF g_count > 0 THEN
			DELETE FROM osp_liguri 
				WHERE cod_osp = p_cod;
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('Record eliminati: ' || SQL%ROWCOUNT);
				DBMS_OUTPUT.PUT_LINE('Ospedale con CODICE ' || p_cod || ' eliminato con successo.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('Ospedale con codice ' || p_cod || ' non trovato. RIPROVARE.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;

	PROCEDURE pcd_trova_con_descr(
		p_des osp_liguri.des_osp%TYPE,
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count FROM osp_liguri WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT osp_liguri.* BULK COLLECT INTO g_osp_aa FROM osp_liguri WHERE des_osp LIKE p_des;
			-- FOR i IN g_osp_aa.FIRST..g_osp_aa.LAST LOOP
			-- oppure
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_osp);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_trova_con_descr;
	
	PROCEDURE pcd_get_selected(
		p_cod osp_liguri.cod_osp%TYPE, 
		p_out_cod OUT INT, 
		p_out_des OUT VARCHAR2, 
		p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR,
		p_out_idutenti OUT INT, 
		p_out_dtmod OUT CHAR
	)AS
	BEGIN
		SELECT osp_liguri.* BULK COLLECT INTO g_osp_aa -- vedere bulk collect (necessario)
			FROM osp_liguri 
		WHERE cod_osp = p_cod;
		FOR i IN g_osp_aa.FIRST..g_osp_aa.LAST LOOP
			p_out_cod := g_osp_aa(i).cod_osp;
			p_out_des := g_osp_aa(i).des_osp;
			p_out_dtini := TO_CHAR(g_osp_aa(i).dt_ini, 'DD/MM/YYYY');
			p_out_dtend := TO_CHAR(g_osp_aa(i).dt_end, 'DD/MM/YYYY');
			p_out_dtcre := TO_CHAR(g_osp_aa(i).dt_cre, 'DD/MM/YYYY');
			p_out_idutenti := g_osp_aa(i).id_utenti;
			p_out_dtmod := TO_CHAR(g_osp_aa(i).dt_mod, 'DD/MM/YYYY');
		END LOOP;
	END pcd_get_selected;
	
	FUNCTION fnc_id_bkp RETURN osp_liguri.cod_osp%TYPE AS
	BEGIN
		SELECT MAX(ID_BKP) + 1 INTO g_count FROM osp_liguri_bkp;
		IF g_count IS NULL THEN
			g_count := 20000001;
		END IF;
		RETURN g_count;
	END fnc_id_bkp;
	
	FUNCTION fnc_trova_aa(
		p_des osp_liguri.des_osp%TYPE,
		p_out OUT INT
	) RETURN osp_aa AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count FROM osp_liguri WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT osp_liguri.* BULK COLLECT INTO g_osp_aa FROM osp_liguri WHERE des_osp LIKE p_des;
			-- FOR i IN g_osp_aa.FIRST..g_osp_aa.LAST LOOP
			-- oppure
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_osp);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
			RETURN g_osp_aa;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END fnc_trova_aa;
	
END pkg_osp_liguri_mgmt;


-- inserisco il primo ospedale - OK
DECLARE
	l_out INT;
BEGIN
	pkg_osp_liguri_mgmt.pcd_inserisci(20000001, 'OSPEDALE A', '21-APR-2021', '31-DIC-2099', '21-APR-2021', 600003, '21-APR-021', l_out);
END;

-- lo reinserisco e mi deve dare errore - OK 
DECLARE
	l_out INT;
BEGIN
	pkg_osp_liguri_mgmt.pcd_inserisci(20000001, 'OSPEDALE A', '21-APR-2021', '31-DIC-2099', '21-APR-2021', 600003, '21-APR-021', l_out);
END;

-- TESTARE FUNZIONI / PCD PRECEDENTI


-- pkg_osp_liguri_mgmt.pcd_get_selected

DECLARE
	l_out_cod INT; 
	l_out_des VARCHAR2(250); 
	l_out_dtini CHAR(10); 
	l_out_dtend CHAR(10); 
	l_out_dtcre CHAR(10);
	l_out_idutenti INT; 
	l_out_dtmod CHAR(10);
BEGIN
	pkg_osp_liguri_mgmt.pcd_get_selected(10001, l_out_cod, l_out_des, l_out_dtini, l_out_dtend, l_out_dtcre, l_out_idutenti, l_out_dtmod);
END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TABELLA 'dipartimenti'

CREATE TABLE dipartimenti
(
	cod_dip INT CONSTRAINT dipartimenti_pk PRIMARY KEY,
	des_dip VARCHAR2(40) NOT NULL, 
	cod_osp INT CONSTRAINT dipartimenti_osp_lig_fk REFERENCES osp_liguri(cod_osp), 
	dt_ini DATE NOT NULL, 
	dt_end DATE, 
	dt_cre DATE NOT NULL, 
	id_utenti INT CONSTRAINT dipartimenti_utenti_fk REFERENCES utenti(id_utenti), 
	dt_mod DATE
);

CREATE TABLE dipartimenti_log
(
	id_bkp INT CONSTRAINT dipartimenti_log_pk PRIMARY KEY,
	data_bkp TIMESTAMP NOT NULL,
	dml_bkp CHAR(1),
	cod_dip INT, -- non modificabile
	old_des_dip VARCHAR2(250),
	des_dip VARCHAR2(250),
	old_cod_osp INT, 
	cod_osp INT,
	dt_ini DATE,
	old_dt_end DATE,
	dt_end DATE,
	dt_cre DATE,
	old_id_utenti INT,
	id_utenti INT,
	old_dt_mod DATE,
	dt_mod DATE
);

CREATE OR REPLACE TRIGGER tr_cmp_dipartimenti_log
FOR INSERT OR UPDATE OR DELETE
ON dipartimenti 
COMPOUND TRIGGER 
	l_dml_bkp dipartimenti_log.dml_bkp%TYPE;
	l_old_des_dip dipartimenti.des_dip%TYPE;
	l_old_cod_osp dipartimenti.cod_osp%TYPE;
	l_old_dt_end dipartimenti.dt_end%TYPE;
	l_old_id_utenti dipartimenti.id_utenti%TYPE;
	l_old_dt_mod dipartimenti.dt_mod%TYPE;
BEFORE EACH ROW IS
	BEGIN
		IF DELETING THEN
			l_dml_bkp := 'D';
			DBMS_OUTPUT.PUT_LINE('Cancellazione ...');
			INSERT INTO dipartimenti_log(id_bkp, data_bkp, dml_bkp, cod_dip, /*old_des_dip,*/ des_dip, /*old_cod_osp,*/ cod_osp, dt_ini, /*old_dt_end,*/ dt_end, dt_cre,
				/*old_id_utenti,*/ id_utenti, dt_mod)
			VALUES(pkg_dipartimenti_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :OLD.cod_dip, :OLD.des_dip, /* :NEW.des_dip, */ :OLD.cod_osp, /* :NEW.cod_osp, */ :OLD.dt_ini,
				:OLD.dt_end, /* :NEW.dt_end, */ :OLD.dt_cre, :OLD.id_utenti, /* :NEW.id_utenti, */ :OLD.dt_mod/* , :NEW.dt_mod */);
		END IF;
	END BEFORE EACH ROW;
AFTER EACH ROW IS
	BEGIN
		IF INSERTING THEN
			DBMS_OUTPUT.PUT_LINE('Inserimento ...');
			l_dml_bkp := 'I';
			INSERT INTO dipartimenti_log(id_bkp, data_bkp, dml_bkp, cod_dip, /*old_des_dip,*/ des_dip, /*old_cod_osp,*/ cod_osp, dt_ini, /*old_dt_end,*/ dt_end, 
				dt_cre, /*old_id_utenti,*/ id_utenti, dt_mod) 
			VALUES(pkg_dipartimenti_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :NEW.cod_dip, /* :OLD.des_dip, */ :NEW.des_dip, /* :OLD.cod_osp, */ :NEW.cod_osp, 
				:NEW.dt_ini, /* :OLD.dt_end, */ :NEW.dt_end, :NEW.dt_cre, /* :OLD.id_utenti, */ :NEW.id_utenti, /* :OLD.dt_mod, */ :NEW.dt_mod);
		END IF;
		IF UPDATING THEN
			DBMS_OUTPUT.PUT_LINE('Aggiornamento ...');
			l_dml_bkp := 'U';
			IF :NEW.des_dip != :OLD.des_dip THEN
				l_old_des_dip := :OLD.des_dip;
			END IF;
			IF :NEW.cod_osp != :OLD.cod_osp THEN
				l_old_cod_osp := :OLD.cod_osp;
			END IF;
			IF :NEW.dt_end != :OLD.dt_end THEN
				l_old_dt_end := :OLD.dt_end;
			END IF;
			IF :NEW.id_utenti != :OLD.id_utenti THEN
				l_old_id_utenti := :OLD.id_utenti;
			END IF;
			IF :NEW.dt_mod != :OLD.dt_mod THEN
				l_old_dt_mod := :OLD.dt_mod;
			END IF;
			INSERT INTO dipartimenti_log(id_bkp, data_bkp, dml_bkp, cod_dip, old_des_dip, des_dip, old_cod_osp, cod_osp, dt_ini, old_dt_end, dt_end, dt_cre, 
				old_id_utenti, id_utenti, old_dt_mod, dt_mod) 
			VALUES(pkg_dipartimenti_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :NEW.cod_dip, l_old_des_dip, :NEW.des_dip, l_old_cod_osp, :NEW.cod_osp, :NEW.dt_ini, 
				l_old_dt_end, :NEW.dt_end, :NEW.dt_cre, l_old_id_utenti, :NEW.id_utenti, l_old_dt_mod, :NEW.dt_mod);
		END IF;
	END AFTER EACH ROW;
END tr_cmp_dipartimenti_log;


CREATE OR REPLACE PACKAGE pkg_dipartimenti_mgmt AS
		
	g_count INT;

	TYPE dip_aa IS TABLE OF dipartimenti%ROWTYPE INDEX BY BINARY_INTEGER;
	g_dip_aa dip_aa;

	PROCEDURE pcd_inserisci(p_cod dipartimenti.cod_dip%TYPE, p_des dipartimenti.des_dip%TYPE, p_cod_osp dipartimenti.cod_osp%TYPE, 
		p_dtini dipartimenti.dt_ini%TYPE, p_dtend dipartimenti.dt_end%TYPE, p_dtcre dipartimenti.dt_cre%TYPE, p_idut dipartimenti.id_utenti%TYPE,
			p_dtmod dipartimenti.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_aggiorna(p_cod dipartimenti.cod_dip%TYPE, p_des dipartimenti.des_dip%TYPE, p_cod_osp dipartimenti.cod_osp%TYPE, 
		p_dtini dipartimenti.dt_ini%TYPE, p_dtend dipartimenti.dt_end%TYPE, p_dtcre dipartimenti.dt_cre%TYPE, p_idut dipartimenti.id_utenti%TYPE,
			p_dtmod dipartimenti.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_elimina(p_cod dipartimenti.cod_osp%TYPE, p_out OUT INT);

	/*PROCEDURE pcd_trova_con_descr(p_des dipartimenti.des_osp%TYPE, p_out OUT INT);*/
	
	PROCEDURE pcd_get_selected(p_cod dipartimenti.cod_dip%TYPE, p_out_cod OUT INT, p_out_des OUT VARCHAR2, p_out_codosp OUT INT, p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, p_out_dtcre OUT CHAR, p_out_idutenti OUT INT, p_out_dtmod OUT CHAR);
	
	-- trovo ID in automatico per inserimento dati nella tabella di backup
	FUNCTION fnc_id_bkp RETURN dipartimenti.cod_dip%TYPE;

	/* FUNCTION fnc_trova_aa(p_des dipartimenti.des_osp%TYPE, p_out OUT INT) RETURN osp_aa;*/

END pkg_dipartimenti_mgmt;


CREATE OR REPLACE PACKAGE BODY pkg_dipartimenti_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cod dipartimenti.cod_dip%TYPE, 
		p_des dipartimenti.des_dip%TYPE, 
		p_cod_osp dipartimenti.cod_osp%TYPE, 
		p_dtini dipartimenti.dt_ini%TYPE, 
		p_dtend dipartimenti.dt_end%TYPE, 
		p_dtcre dipartimenti.dt_cre%TYPE, 
		p_idut dipartimenti.id_utenti%TYPE,
		p_dtmod dipartimenti.dt_mod%TYPE,
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count	-- VEDERE VALIDAZIONE PER P_COD E P_DES
			FROM dipartimenti 
		WHERE cod_dip = p_cod AND des_dip = p_des;
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('Codice e descrizione già presenti a db. Errore di inserimento');
		ELSE
			SELECT COUNT(cod_dip) INTO g_count
				FROM dipartimenti 
			WHERE cod_dip = p_cod;
			IF g_count > 0 THEN
				DBMS_OUTPUT.PUT_LINE('Codice già presente a db. Non inserito');
			ELSE
				SELECT COUNT(cod_dip) INTO g_count
					FROM dipartimenti 
				WHERE des_dip = p_des;
				IF g_count > 0 THEN
					DBMS_OUTPUT.PUT_LINE('Descrizione già presente a db. Non inserito');
				ELSE
					INSERT INTO dipartimenti(cod_dip, des_dip, cod_osp, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
					VALUES (p_cod, UPPER(p_des), p_cod_osp, p_dtini, p_dtend, p_dtcre, p_idut, NULL);
					COMMIT;
					p_out := 1;
					DBMS_OUTPUT.PUT_LINE('Codice dipartimento: ' || p_cod);
					DBMS_OUTPUT.PUT_LINE('Descrizione dipartimento: ' || p_des);
				END IF;
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE; -- moved under ROLLBACK
	END pcd_inserisci;
	
	PROCEDURE pcd_aggiorna( -- si può aggiornare solo la descrizione e altri campi. NON il codice dipartimento)
		p_cod dipartimenti.cod_dip%TYPE, 
		p_des dipartimenti.des_dip%TYPE, 
		p_cod_osp dipartimenti.cod_osp%TYPE, 
		p_dtini dipartimenti.dt_ini%TYPE, 
		p_dtend dipartimenti.dt_end%TYPE, 
		p_dtcre dipartimenti.dt_cre%TYPE, 
		p_idut dipartimenti.id_utenti%TYPE,
		p_dtmod dipartimenti.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count 
			FROM dipartimenti
		WHERE cod_dip = p_cod;
		IF g_count > 0 THEN
			UPDATE dipartimenti 
				SET des_dip = p_des, cod_osp = p_cod_osp, dt_ini = p_dtini, dt_end = p_dtend, dt_cre = p_dtcre, id_utenti = p_idut, dt_mod = p_dtmod     
			WHERE cod_dip = p_cod;
			SELECT COUNT(cod_dip) INTO g_count 
				FROM dipartimenti 
			WHERE des_dip = p_des;
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('DIPARTIMENTO con descrizione ' || p_des || ' già presente. Non aggiornato.');
				ROLLBACK;
			ELSE
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('DIPARTIMENTO con descrizione ' || p_des || ' aggiornato.');
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_cod dipartimenti.cod_osp%TYPE, p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count 
			FROM dipartimenti 
		WHERE cod_dip = p_cod;
		IF g_count > 0 THEN
			DELETE FROM dipartimenti 
				WHERE cod_dip = p_cod;
				COMMIT;
				p_out := 1;
				--DBMS_OUTPUT.PUT_LINE('Record eliminati: ' || SQL%ROWCOUNT);
				DBMS_OUTPUT.PUT_LINE('DIPARTIMENTO con CODICE ' || p_cod || ' eliminato con successo.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('DIPARTIMENTO con codice ' || p_cod || ' non trovato. RIPROVARE.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;

	/* PROCEDURE pcd_trova_con_descr(
		p_des dipartimenti.des_dip%TYPE,
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count FROM dipartimenti WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT dipartimenti.* BULK COLLECT INTO g_osp_aa FROM dipartimenti WHERE des_osp LIKE p_des;
			-- FOR i IN g_osp_aa.FIRST..g_osp_aa.LAST LOOP
			-- oppure
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_osp);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_trova_con_descr; */
	
	PROCEDURE pcd_get_selected(
		p_cod dipartimenti.cod_dip%TYPE, 
		p_out_cod OUT INT, 
		p_out_des OUT VARCHAR2, 
		p_out_codosp OUT INT,
		p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR,
		p_out_idutenti OUT INT, 
		p_out_dtmod OUT CHAR
	)AS
	BEGIN
		SELECT dipartimenti.* BULK COLLECT INTO g_dip_aa -- vedere bulk collect (necessario)
			FROM dipartimenti 
		WHERE cod_dip = p_cod;
		FOR i IN g_dip_aa.FIRST .. g_dip_aa.LAST LOOP
			p_out_cod := g_dip_aa(i).cod_dip;
			p_out_des := g_dip_aa(i).des_dip;
			p_out_codosp := g_dip_aa(i).cod_osp; 
			p_out_dtini := TO_CHAR(g_dip_aa(i).dt_ini, 'DD/MM/YYYY');
			p_out_dtend := TO_CHAR(g_dip_aa(i).dt_end, 'DD/MM/YYYY');
			p_out_dtcre := TO_CHAR(g_dip_aa(i).dt_cre, 'DD/MM/YYYY');
			p_out_idutenti := g_dip_aa(i).id_utenti;
			p_out_dtmod := TO_CHAR(g_dip_aa(i).dt_mod, 'DD/MM/YYYY');
		END LOOP;
	END pcd_get_selected;
	
	FUNCTION fnc_id_bkp RETURN dipartimenti.cod_dip%TYPE AS
	BEGIN
		SELECT MAX(id_bkp) + 1 INTO g_count FROM dipartimenti_log;
		IF g_count IS NULL THEN
			g_count := 40000001;
		END IF;
		RETURN g_count;
	END fnc_id_bkp;
	
	/*FUNCTION fnc_trova_aa(
		p_des dipartimenti.des_osp%TYPE,
		p_out OUT INT
	) RETURN osp_aa AS
	BEGIN
		SELECT COUNT(cod_osp) INTO g_count FROM dipartimenti WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT dipartimenti.* BULK COLLECT INTO g_osp_aa FROM dipartimenti WHERE des_osp LIKE p_des;
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_osp);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
			RETURN g_osp_aa;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END fnc_trova_aa;*/
	
END pkg_dipartimenti_mgmt;


-- test pkg_dipartimenti_mgmt.pcd_inserisci

	-- inserisco il primo dipartimento -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_inserisci(1, 'TEST DIPARTIMENTO', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- provo a inserirlo di nuovo e mi da errore per des e cod -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_inserisci(1, 'TEST DIPARTIMENTO', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- provo a inserire un dipart con stessa des e codice diverso. errore su des -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_inserisci(2, 'TEST DIPARTIMENTO', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- provo a inserire un dipart con stesso cod ma des diversa. errore su codice -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_inserisci(1, 'TEST DIPARTIMENTO 2', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;


-- test pkg_dipartimenti_mgmt.pcd_aggiorna

	-- aggiorno il dipartimento senza cambiare nessun dato -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_aggiorna(1, 'TEST DIPARTIMENTO', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- aggiorno il dipartimento -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_aggiorna(1, 'TEST DIPARTIMENTO 2', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
-- test pkg_dipartimenti_mgmt.pcd_elimina
	-- elimino dipartimento esistente -- ok

	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_elimina(20004, l_out);
	END;
	
	-- elimino di nuovo lo stesso dipartimento e non lo trova -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_dipartimenti_mgmt.pcd_elimina(20004, l_out);
	END;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE unita_op 
(
	cod_uop VARCHAR2(2) CONSTRAINT unita_op_fk PRIMARY KEY, 
	des_uop VARCHAR2(40) NOT NULL,
	cod_dip INT CONSTRAINT unita_op_dipart_fk REFERENCES dipartimenti(cod_dip) NOT NULL,
	dt_ini DATE NOT NULL,
	dt_end DATE,
	dt_cre DATE NOT NULL,
	id_utenti INT CONSTRAINT unita_op_utenti_fk REFERENCES utenti(id_utenti) NOT NULL,
	dt_mod DATE
);

CREATE TABLE unita_op_log
(
	id_bkp INT CONSTRAINT unita_op_log_pk PRIMARY KEY,
	data_bkp TIMESTAMP NOT NULL,
	dml_bkp CHAR(1),
	cod_uop VARCHAR2(2), -- non modificabile per non violare integrità db
	old_des_uop VARCHAR2(40),
	des_uop VARCHAR2(40) NOT NULL,
	old_cod_dip INT,
	cod_dip INT,
	old_dt_ini DATE,
	dt_ini DATE,
	old_dt_end DATE,
	dt_end DATE,
	dt_cre DATE,
	old_id_utenti INT,
	id_utenti INT,
	old_dt_mod DATE,
	dt_mod DATE
);


CREATE OR REPLACE TRIGGER tr_cmp_unita_op_log
FOR INSERT OR UPDATE OR DELETE
ON unita_op 
COMPOUND TRIGGER 
	l_dml_bkp unita_op_log.dml_bkp%TYPE;
	l_old_des_uop unita_op.des_uop%TYPE;
	l_old_cod_dip unita_op.cod_dip%TYPE;
	l_old_dt_ini unita_op.dt_ini%TYPE;
	l_old_dt_end unita_op.dt_end%TYPE;
	l_old_id_utenti unita_op.id_utenti%TYPE;
	l_old_dt_mod unita_op.dt_mod%TYPE;
BEFORE EACH ROW IS
	BEGIN
		IF DELETING THEN
			l_dml_bkp := 'D';
			DBMS_OUTPUT.PUT_LINE('Cancellazione ...');
			INSERT INTO unita_op_log(id_bkp, data_bkp, dml_bkp, cod_uop, des_uop, cod_dip, dt_ini, dt_end, dt_cre, id_utenti, dt_mod)
			VALUES(pkg_unita_op_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :OLD.cod_uop, :OLD.des_uop, :OLD.cod_dip, :OLD.dt_ini, :OLD.dt_end, :OLD.dt_cre, 
				:OLD.id_utenti, :OLD.dt_mod);
		END IF;
	END BEFORE EACH ROW;
AFTER EACH ROW IS
	BEGIN
		IF INSERTING THEN
			DBMS_OUTPUT.PUT_LINE('Inserimento ...');
			l_dml_bkp := 'I';
			INSERT INTO unita_op_log(id_bkp, data_bkp, dml_bkp, cod_uop, des_uop, cod_dip, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
			VALUES(pkg_unita_op_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :NEW.cod_uop, :NEW.des_uop, :NEW.cod_dip, :NEW.dt_ini, :NEW.dt_end, :NEW.dt_cre,
				:NEW.id_utenti, :NEW.dt_mod);
		END IF;
		IF UPDATING THEN
			DBMS_OUTPUT.PUT_LINE('Aggiornamento ...');
			l_dml_bkp := 'U';
			IF :NEW.des_uop != :OLD.des_uop THEN
				l_old_des_uop := :OLD.des_uop;
			END IF;
			IF :NEW.cod_dip != :OLD.cod_dip THEN
				l_old_cod_dip := :OLD.cod_dip;
			END IF;
			IF :NEW.dt_ini != :OLD.dt_ini THEN
				l_old_dt_ini := :OLD.dt_ini;
			END IF;
			IF :NEW.dt_end != :OLD.dt_end THEN
				l_old_dt_end := :OLD.dt_end;
			END IF;
			IF :NEW.id_utenti != :OLD.id_utenti THEN
				l_old_id_utenti := :OLD.id_utenti;
			END IF;
			IF :NEW.dt_mod != :OLD.dt_mod THEN
				l_old_dt_mod := :OLD.dt_mod;
			END IF;
			INSERT INTO unita_op_log(id_bkp, data_bkp, dml_bkp, cod_uop, old_des_uop, des_uop, old_cod_dip, cod_dip, old_dt_ini, dt_ini, old_dt_end, dt_end, 
				dt_cre, old_id_utenti, id_utenti, old_dt_mod, dt_mod) 
			VALUES(pkg_unita_op_mgmt.fnc_id_bkp(), SYSDATE, l_dml_bkp, :NEW.cod_uop, l_old_des_uop, :NEW.des_uop, l_old_cod_dip, :NEW.cod_dip, l_old_dt_ini, 
				:NEW.dt_ini, l_old_dt_end, :NEW.dt_end, :NEW.dt_cre, l_old_id_utenti, :NEW.id_utenti, l_old_dt_mod, :NEW.dt_mod);
		END IF;
	END AFTER EACH ROW;

END tr_cmp_unita_op_log;


CREATE OR REPLACE PACKAGE pkg_unita_op_mgmt AS
		
	g_count INT;

	TYPE uop_aa IS TABLE OF unita_op%ROWTYPE INDEX BY BINARY_INTEGER;
	g_uop_aa uop_aa;

	PROCEDURE pcd_inserisci(p_cod unita_op.cod_uop%TYPE, p_des unita_op.des_uop%TYPE, p_coddip unita_op.cod_dip%TYPE, p_dtini unita_op.dt_ini%TYPE, 
		p_dtend unita_op.dt_end%TYPE, p_dtcre unita_op.dt_cre%TYPE, p_idut unita_op.id_utenti%TYPE, p_dtmod unita_op.dt_mod%TYPE, p_out OUT INT);
		
	PROCEDURE pcd_aggiorna(p_cod unita_op.cod_uop%TYPE, p_des unita_op.des_uop%TYPE, p_coddip unita_op.cod_dip%TYPE, p_dtini unita_op.dt_ini%TYPE, 
		p_dtend unita_op.dt_end%TYPE, p_dtcre unita_op.dt_cre%TYPE, p_idut unita_op.id_utenti%TYPE, p_dtmod unita_op.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_elimina(p_cod unita_op.cod_uop%TYPE, p_out OUT INT);
	
	PROCEDURE pcd_get_selected(p_cod unita_op.cod_uop%TYPE, p_out_cod OUT VARCHAR2, p_out_des OUT VARCHAR2, p_out_coddip OUT INT, p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, p_out_dtcre OUT CHAR, p_out_idutenti OUT INT, p_out_dtmod OUT CHAR);
	
	FUNCTION fnc_id_bkp RETURN unita_op.cod_uop%TYPE;

	/* FUNCTION fnc_trova_aa(p_des unita_op.des_osp%TYPE, p_out OUT INT) RETURN osp_aa; */

END pkg_unita_op_mgmt;


CREATE OR REPLACE PACKAGE BODY pkg_unita_op_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cod unita_op.cod_uop%TYPE, 
		p_des unita_op.des_uop%TYPE, 
		p_coddip unita_op.cod_dip%TYPE, 
		p_dtini unita_op.dt_ini%TYPE, 
		p_dtend unita_op.dt_end%TYPE, 
		p_dtcre unita_op.dt_cre%TYPE, 
		p_idut unita_op.id_utenti%TYPE,
		p_dtmod unita_op.dt_mod%TYPE,
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_uop) INTO g_count	-- VEDERE VALIDAZIONE PER P_COD E P_DES
			FROM unita_op 
		WHERE cod_uop = UPPER(p_cod) AND des_uop = UPPER(p_des);
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('Codice e descrizione già presenti a db. Errore di inserimento');
		ELSE
			SELECT COUNT(cod_uop) INTO g_count
				FROM unita_op 
			WHERE cod_uop = UPPER(p_cod);
			IF g_count > 0 THEN
				DBMS_OUTPUT.PUT_LINE('Codice ' || UPPER(p_cod) || ' già presente a db. Non inserito');
			ELSE
				SELECT COUNT(cod_uop) INTO g_count
					FROM unita_op 
				WHERE des_uop = UPPER(p_des);
				IF g_count > 0 THEN
					DBMS_OUTPUT.PUT_LINE('Descrizione ' || UPPER(p_des) || ' già presente a db. Non inserito');
				ELSE
					INSERT INTO unita_op(cod_uop, des_uop, cod_dip, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
					VALUES (UPPER(p_cod), UPPER(p_des), p_coddip, p_dtini, p_dtend, p_dtcre, p_idut, NULL);
					COMMIT;
					p_out := 1;
					DBMS_OUTPUT.PUT_LINE('Codice UNITA OPERATIVA: ' || p_cod);
					DBMS_OUTPUT.PUT_LINE('Descrizione UNITA OPERATIVA: ' || p_des);
				END IF;
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE; -- moved under ROLLBACK
	END pcd_inserisci;
	
	PROCEDURE pcd_aggiorna( -- si può aggiornare solo la descrizione e altri campi. NON il codice dipartimento)
		p_cod unita_op.cod_uop%TYPE, 
		p_des unita_op.des_uop%TYPE, 
		p_coddip unita_op.cod_dip%TYPE, 
		p_dtini unita_op.dt_ini%TYPE, 
		p_dtend unita_op.dt_end%TYPE, 
		p_dtcre unita_op.dt_cre%TYPE, 
		p_idut unita_op.id_utenti%TYPE,
		p_dtmod unita_op.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_uop) INTO g_count 
			FROM unita_op
		WHERE cod_uop = UPPER(p_cod);
		IF g_count > 0 THEN
			UPDATE unita_op 
				SET des_uop = UPPER(p_des), cod_dip = p_coddip, dt_ini = p_dtini, dt_end = p_dtend, dt_cre = p_dtcre, id_utenti = p_idut, dt_mod = p_dtmod     
			WHERE cod_uop = UPPER(p_cod);
			SELECT COUNT(cod_uop) INTO g_count 
				FROM unita_op 
			WHERE des_uop = UPPER(p_des);
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con descrizione ' || UPPER(p_des) || ' già presente. Non aggiornata.');
				ROLLBACK;
			ELSE
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con descrizione ' || UPPER(p_des) || ' aggiornata.');
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_cod unita_op.cod_uop%TYPE, 
		p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(cod_uop) INTO g_count 
			FROM unita_op 
		WHERE cod_uop = UPPER(p_cod);
		IF g_count > 0 THEN
			DELETE FROM unita_op 
				WHERE cod_uop = UPPER(p_cod);
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con CODICE ' || UPPER(p_cod) || ' eliminata con successo.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con codice ' || UPPER(p_cod) || ' non trovata. RIPROVARE.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;
	
	PROCEDURE pcd_get_selected(
		p_cod unita_op.cod_uop%TYPE, 
		p_out_cod OUT VARCHAR2, 
		p_out_des OUT VARCHAR2, 
		p_out_coddip OUT INT, 
		p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR, 
		p_out_idutenti OUT INT, 
		p_out_dtmod OUT CHAR
	)AS
	BEGIN
		SELECT unita_op.* BULK COLLECT INTO g_uop_aa -- vedere bulk collect (necessario)
			FROM unita_op 
		WHERE cod_uop = UPPER(p_cod);
		FOR i IN g_uop_aa.FIRST .. g_uop_aa.LAST LOOP
			p_out_cod := g_uop_aa(i).cod_uop;
			p_out_des := g_uop_aa(i).des_uop;
			p_out_coddip := g_uop_aa(i).cod_dip; 
			p_out_dtini := TO_CHAR(g_uop_aa(i).dt_ini, 'DD/MM/YYYY');
			p_out_dtend := TO_CHAR(g_uop_aa(i).dt_end, 'DD/MM/YYYY');
			p_out_dtcre := TO_CHAR(g_uop_aa(i).dt_cre, 'DD/MM/YYYY');
			p_out_idutenti := g_uop_aa(i).id_utenti;
			p_out_dtmod := TO_CHAR(g_uop_aa(i).dt_mod, 'DD/MM/YYYY');
		END LOOP;
	END pcd_get_selected;
	
	FUNCTION fnc_id_bkp RETURN unita_op.cod_uop%TYPE AS
	BEGIN
		SELECT MAX(id_bkp) + 1 INTO g_count FROM unita_op_log;
		IF g_count IS NULL THEN
			g_count := 40000001;
		END IF;
		RETURN g_count;
	END fnc_id_bkp;
	
	/* FUNCTION fnc_trova_aa(
		p_des unita_op.des_osp%TYPE,
		p_out OUT INT
	) RETURN osp_aa AS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count FROM unita_op WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT unita_op.* BULK COLLECT INTO g_osp_aa FROM unita_op WHERE des_osp LIKE p_des;
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_dip);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
			RETURN g_osp_aa;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END fnc_trova_aa; */
	
END pkg_unita_op_mgmt;


-- test pcd_inserisci

	-- inserisco la prima unita op -- ok

	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('a1', 'GESTIONE TECNICA UNITA OP', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
		
	-- provo a inserirlo di nuovo e mi da errore per des e cod -- ok
		
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('a1', 'GESTIONE TECNICA UNITA OP', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
		
	-- provo a inserire di nuovo con stessa des e codice diverso. errore su des -- ok
		
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('aa1', 'GESTIONE TECNICA UNITA OP', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
		
	-- provo a inserire un unita op con stesso cod ma des diversa. errore su codice -- ok
		
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('a1', 'GESTIONE TECNICA UNITA OP 2', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- inserisco altre unita operative
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('b21', 'GESTIONE CLINICA', 10002, '29-APR-2021', '31-DIC-2050', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_inserisci('C48', 'ANATOMIA PATOLOGICA', 10002, '29-APR-2021', '31-DIC-2050', '29-APR-2021', 600001, NULL, l_out);
	END;
	

-- test pcd_aggiorna

	-- aggiorno unita op senza cambiare nessun dato -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_aggiorna('a1', 'GESTIONE TECNICA UNITA OP 2', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- aggiorno unita op con des già esistente. non aggiorna -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_aggiorna('a1', 'GESTIONE CLINICA', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	-- aggiorno unita op  -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_aggiorna('a1', 'GESTIONE TECNICA UNITA OP', 10001, '29-APR-2021', '31-DIC-2099', '29-APR-2021', 600001, NULL, l_out);
	END;
	
	
-- test pcd_elimina
	
	-- elimino esistente -- ok

	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_elimina('a1', l_out);
	END;
	
	-- elimino di nuovo e non lo trovo -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_unita_op_mgmt.pcd_elimina('a1', l_out);
	END;
	
-- test pcd_get_selected
	
	DECLARE
		l_out_cod VARCHAR2(2);
		l_out_des VARCHAR2(40);
		l_out_coddip INT; 
		l_out_dtini CHAR(10);
		l_out_dtend CHAR(10);
		l_out_dtcre CHAR(10);
		l_out_idutenti INT;
		l_out_dtmod CHAR(10);
	BEGIN
		pkg_unita_op_mgmt.pcd_get_selected('B2', l_out_cod, l_out_des, l_out_coddip, l_out_dtini, l_out_dtend, l_out_dtcre, l_out_idutenti, l_out_dtmod);
	END;

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
	
CREATE TABLE stabilimenti
(
	cod_stab INT CONSTRAINT stabilimenti_fk PRIMARY KEY,
	descrizione VARCHAR2(100),
	dt_ini DATE NOT NULL,
	dt_end DATE,
	dt_cre DATE NOT NULL,
	id_utenti INT CONSTRAINT stabilimenti_utenti_fk REFERENCES utenti(id_utenti) NOT NULL,
	dt_mod DATE
);

CREATE TABLE stabilimenti_log
(
	id_log INT CONSTRAINT stabilimenti_log_pk PRIMARY KEY,
	data_log TIMESTAMP NOT NULL,
	dml_log CHAR(1),
	cod_stab INT,
	old_descrizione VARCHAR2(100),
	descrizione VARCHAR2(100),
	old_dt_ini DATE,
	dt_ini DATE,
	old_dt_end DATE,
	dt_end DATE,
	dt_cre DATE,
	old_id_utenti INT,
	id_utenti INT,
	old_dt_mod DATE,
	dt_mod DATE
);

CREATE OR REPLACE TRIGGER tr_cmp_stabilimenti_log
FOR INSERT OR UPDATE OR DELETE
ON stabilimenti 
COMPOUND TRIGGER 
	l_dml_log stabilimenti_log.dml_log%TYPE; 
	l_old_descrizione stabilimenti.descrizione%TYPE;
	l_old_dt_ini stabilimenti.dt_ini%TYPE;
	l_old_dt_end stabilimenti.dt_end%TYPE;
	l_old_id_utenti stabilimenti.id_utenti%TYPE;
	l_old_dt_mod stabilimenti.dt_mod%TYPE;
BEFORE EACH ROW IS
	BEGIN
		IF DELETING THEN
			l_dml_log := 'D';
			DBMS_OUTPUT.PUT_LINE('Cancellazione ...');
			INSERT INTO stabilimenti_log(id_log, data_log, dml_log, cod_stab, descrizione, dt_ini, dt_end, dt_cre, id_utenti, dt_mod)
			VALUES(pkg_stabilimenti_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :OLD.cod_stab, :OLD.descrizione, :OLD.dt_ini, :OLD.dt_end, :OLD.dt_cre, 
				:OLD.id_utenti, :OLD.dt_mod);
		END IF;
	END BEFORE EACH ROW;
AFTER EACH ROW IS
	BEGIN
		IF INSERTING THEN
			DBMS_OUTPUT.PUT_LINE('Inserimento ...');
			l_dml_log := 'I';
			INSERT INTO stabilimenti_log(id_log, data_log, dml_log, cod_stab, descrizione, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
			VALUES(pkg_stabilimenti_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :NEW.cod_stab, :NEW.descrizione, :NEW.dt_ini, :NEW.dt_end, :NEW.dt_cre,
				:NEW.id_utenti, :NEW.dt_mod);
		END IF;
		IF UPDATING THEN
			DBMS_OUTPUT.PUT_LINE('Aggiornamento ...');
			l_dml_log := 'U';
			IF :NEW.descrizione != :OLD.descrizione THEN
				l_old_descrizione := :OLD.descrizione;
			END IF;
			IF :NEW.dt_ini != :OLD.dt_ini THEN
				l_old_dt_ini := :OLD.dt_ini;
			END IF;
			IF :NEW.dt_end != :OLD.dt_end THEN
				l_old_dt_end := :OLD.dt_end;
			END IF;
			IF :NEW.id_utenti != :OLD.id_utenti THEN
				l_old_id_utenti := :OLD.id_utenti;
			END IF;
			IF :NEW.dt_mod != :OLD.dt_mod THEN
				l_old_dt_mod := :OLD.dt_mod;
			END IF;
			INSERT INTO stabilimenti_log(id_log, data_log, dml_log, cod_stab, old_descrizione, descrizione, old_dt_ini, dt_ini, old_dt_end, dt_end, dt_cre, 
				old_id_utenti, id_utenti, old_dt_mod, dt_mod) 
			VALUES(pkg_stabilimenti_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :NEW.cod_stab, l_old_descrizione, :NEW.descrizione, l_old_dt_ini, :NEW.dt_ini, 
				l_old_dt_end, :NEW.dt_end, :NEW.dt_cre, l_old_id_utenti, :NEW.id_utenti, l_old_dt_mod, :NEW.dt_mod);
		END IF;
	END AFTER EACH ROW;

END tr_cmp_stabilimenti_log;


CREATE OR REPLACE PACKAGE pkg_stabilimenti_mgmt AS -- uso CURSORE invece di ARRAY. dovrei usare un RECORD?
		
	g_count INT;

	TYPE stab_aa IS TABLE OF stabilimenti%ROWTYPE INDEX BY BINARY_INTEGER;
	g_stab_aa stab_aa;

	PROCEDURE pcd_inserisci(p_cod stabilimenti.cod_stab%TYPE, p_des stabilimenti.descrizione%TYPE, p_dtini stabilimenti.dt_ini%TYPE, 
		p_dtend stabilimenti.dt_end%TYPE, p_dtcre stabilimenti.dt_cre%TYPE, p_idut stabilimenti.id_utenti%TYPE, p_dtmod stabilimenti.dt_mod%TYPE, p_out OUT INT);
		
	PROCEDURE pcd_aggiorna(p_cod stabilimenti.cod_stab%TYPE, p_des stabilimenti.descrizione%TYPE, p_dtini stabilimenti.dt_ini%TYPE, 
		p_dtend stabilimenti.dt_end%TYPE, p_dtcre stabilimenti.dt_cre%TYPE, p_idut stabilimenti.id_utenti%TYPE, p_dtmod stabilimenti.dt_mod%TYPE, p_out OUT INT);

	PROCEDURE pcd_elimina(p_cod stabilimenti.cod_stab%TYPE, p_out OUT INT);
	
	PROCEDURE pcd_get_selected(p_cod stabilimenti.cod_stab%TYPE, p_out_cod OUT VARCHAR2, p_out_des OUT VARCHAR2, p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, p_out_dtcre OUT CHAR, p_out_idutenti OUT INT, p_out_dtmod OUT CHAR);
	
	FUNCTION fnc_id_log RETURN stabilimenti.cod_stab%TYPE;

	/* FUNCTION fnc_trova_aa(p_des stabilimenti.des_osp%TYPE, p_out OUT INT) RETURN osp_aa; */

END pkg_stabilimenti_mgmt;

CREATE OR REPLACE PACKAGE BODY pkg_stabilimenti_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cod stabilimenti.cod_stab%TYPE, 
		p_des stabilimenti.descrizione%TYPE, 
		p_dtini stabilimenti.dt_ini%TYPE, 
		p_dtend stabilimenti.dt_end%TYPE, 
		p_dtcre stabilimenti.dt_cre%TYPE, 
		p_idut stabilimenti.id_utenti%TYPE, 
		p_dtmod stabilimenti.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_stab) INTO g_count	-- VEDERE VALIDAZIONE PER P_COD E P_DES
			FROM stabilimenti 
		WHERE cod_stab = UPPER(p_cod) AND descrizione = UPPER(p_des);
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('Codice e descrizione già presenti a db. STABILIMENTO non inserito.');
		ELSE
			SELECT COUNT(cod_stab) INTO g_count
				FROM stabilimenti 
			WHERE cod_stab = UPPER(p_cod);
			IF g_count > 0 THEN
				DBMS_OUTPUT.PUT_LINE('Codice ' || UPPER(p_cod) || ' già presente a db. Non inserito');
			ELSE
				SELECT COUNT(cod_stab) INTO g_count
					FROM stabilimenti 
				WHERE descrizione = UPPER(p_des);
				IF g_count > 0 THEN
					DBMS_OUTPUT.PUT_LINE('Descrizione ' || UPPER(p_des) || ' già presente a db. Non inserito');
				ELSE
					INSERT INTO stabilimenti(cod_stab, descrizione, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
					VALUES (UPPER(p_cod), UPPER(p_des), p_dtini, p_dtend, p_dtcre, p_idut, NULL);
					COMMIT;
					p_out := 1;
					DBMS_OUTPUT.PUT_LINE('Codice UNITA OPERATIVA: ' || p_cod);
					DBMS_OUTPUT.PUT_LINE('Descrizione UNITA OPERATIVA: ' || p_des);
				END IF;
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE; -- moved under ROLLBACK
	END pcd_inserisci;
	
 	PROCEDURE pcd_aggiorna(	-- non è possibile aggiornare il codice per integrità db 
		p_cod stabilimenti.cod_stab%TYPE, 
		p_des stabilimenti.descrizione%TYPE, 
		p_dtini stabilimenti.dt_ini%TYPE, 
		p_dtend stabilimenti.dt_end%TYPE, 
		p_dtcre stabilimenti.dt_cre%TYPE, 
		p_idut stabilimenti.id_utenti%TYPE, 
		p_dtmod stabilimenti.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_stab) INTO g_count 
			FROM stabilimenti
		WHERE cod_stab = UPPER(p_cod);
		IF g_count > 0 THEN
			UPDATE stabilimenti 
				SET descrizione = UPPER(p_des), dt_ini = p_dtini, dt_end = p_dtend, dt_cre = p_dtcre, id_utenti = p_idut, dt_mod = p_dtmod     
			WHERE cod_stab = UPPER(p_cod);
			SELECT COUNT(cod_stab) INTO g_count 
				FROM stabilimenti 
			WHERE descrizione = UPPER(p_des);
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con descrizione ' || UPPER(p_des) || ' già presente. Non aggiornata.');
				ROLLBACK;
			ELSE
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con descrizione ' || UPPER(p_des) || ' aggiornata.');
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_cod stabilimenti.cod_stab%TYPE, 
		p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(cod_stab) INTO g_count 
			FROM stabilimenti 
		WHERE cod_stab = UPPER(p_cod);
		IF g_count > 0 THEN
			DELETE FROM stabilimenti 
				WHERE cod_stab = UPPER(p_cod);
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('STABILIMENTO con CODICE ' || UPPER(p_cod) || ' eliminato con successo.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('STABILIMENTO con codice ' || UPPER(p_cod) || ' non trovato. RIPROVARE.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;
	
	PROCEDURE pcd_get_selected(
		p_cod stabilimenti.cod_stab%TYPE, 
		p_out_cod OUT VARCHAR2, 
		p_out_des OUT VARCHAR2, 
		p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR, 
		p_out_idutenti OUT INT, 
		p_out_dtmod OUT CHAR
	)AS
	BEGIN
		SELECT stabilimenti.* BULK COLLECT INTO g_stab_aa -- vedere bulk collect (necessario)
			FROM stabilimenti 
		WHERE cod_stab = UPPER(p_cod);
		FOR i IN g_stab_aa.FIRST .. g_stab_aa.LAST LOOP
			p_out_cod := g_stab_aa(i).cod_stab;
			p_out_des := g_stab_aa(i).descrizione;
			p_out_dtini := TO_CHAR(g_stab_aa(i).dt_ini, 'DD/MM/YYYY');
			p_out_dtend := TO_CHAR(g_stab_aa(i).dt_end, 'DD/MM/YYYY');
			p_out_dtcre := TO_CHAR(g_stab_aa(i).dt_cre, 'DD/MM/YYYY');
			p_out_idutenti := g_stab_aa(i).id_utenti;
			p_out_dtmod := TO_CHAR(g_stab_aa(i).dt_mod, 'DD/MM/YYYY');
		END LOOP;
	END pcd_get_selected;
	
	FUNCTION fnc_id_log RETURN stabilimenti.cod_stab%TYPE AS
	BEGIN
		SELECT MAX(id_log) + 1 INTO g_count FROM stabilimenti_log;
		IF g_count IS NULL THEN
			g_count := 40000001;
		END IF;
		RETURN g_count;
	END fnc_id_log;
	
	/* FUNCTION fnc_trova_aa(
		p_des stabilimenti.des_osp%TYPE,
		p_out OUT INT
	) RETURN osp_aa AS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count FROM stabilimenti WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT stabilimenti.* BULK COLLECT INTO g_osp_aa FROM stabilimenti WHERE des_osp LIKE p_des;
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_dip);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
			RETURN g_osp_aa;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con descrizione o parte di descrizione ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END fnc_trova_aa; */
	
END pkg_stabilimenti_mgmt;

-- test pcd_inserisci

	-- INSERISCO STABILIMENTO	 -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_inserisci(1, 'OSPEDALE MICONE', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;
	
	-- lo inserisco di nuovo e mi da err su des e cod -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_inserisci(1, 'OSPEDALE MICONE', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;

	-- inserisco di nuovo con stesso cod ma descr diversa: da err su cod -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_inserisci(1, 'OSPEDALE MICONE BIS', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;
	
	-- inserisco di nuovo con stessa des ma cod diverso : da err su des -- ok
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_inserisci(2, 'OSPEDALE MICONE', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;
	
	-- INSERISCO UN ALTRO STABILIMENTO	 -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_inserisci(2, 'OSPEDALE MICONE 2', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;
	
	
-- test pcd_aggiorna

	-- aggiorno stabilimento senza cambiare nessun dato -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_aggiorna(1, 'OSPEDALE MICONE', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600001, NULL, l_out);
	END;
	
	-- aggiorno il dipartimento (nuova des e nuovo id utente) -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_aggiorna(1, 'OSPEDALE MICONE AGG', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600002, NULL, l_out);
	END;
	
	-- aggiorno di nuovo senza cambiare dati -- ok
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_aggiorna(1, 'OSPEDALE MICONE AGG', '12-MAG-2021', '31-DIC-2099', '12-MAG-2021', 600002, NULL, l_out);
	END;
	
	-- test pcd_get_selected
	DECLARE
		l_out_cod INT; 
		l_out_des VARCHAR2(250);
		l_out_dtini CHAR(10); 
		l_out_dtend CHAR(10); 
		l_out_dtcre CHAR(10); 
		l_out_idutenti INT; 
		l_out_dtmod CHAR(10);
	BEGIN
		pkg_stabilimenti_mgmt.pcd_get_selected(1, l_out_cod, l_out_des, l_out_dtini, l_out_dtend, l_out_dtcre, l_out_idutenti, l_out_dtmod);
	END;
	
	-- test pcd_elimina
	
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_elimina(1, l_out);
	END;
	
	-- elimino di nuovo e non lo trovo -- ok
		
	DECLARE
		l_out INT;
	BEGIN
		pkg_stabilimenti_mgmt.pcd_elimina(1, l_out);
	END;
	
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE moduli
(
	cod_mod INT CONSTRAINT moduli_pk PRIMARY KEY,
	des_mod VARCHAR2(250) NOT NULL,
	cod_dip INT CONSTRAINT moduli_dipartimenti_fk REFERENCES dipartimenti(cod_dip) NOT NULL,
	cod_uop VARCHAR2(2) CONSTRAINT moduli_unita_op_fk REFERENCES unita_op(cod_uop) NOT NULL,
	dt_ini DATE NOT NULL,
	dt_end DATE,
	dt_cre DATE NOT NULL,
	id_utenti INT CONSTRAINT moduli_utenti_fk REFERENCES utenti(id_utenti) NOT NULL,
	dt_mod DATE
);

CREATE TABLE moduli_log
(
	id_log INT CONSTRAINT moduli_log_pk PRIMARY KEY,
	data_log TIMESTAMP NOT NULL,
	dml_log CHAR(1),
	cod_mod INT,
	old_des_mod VARCHAR2(100),
	des_mod VARCHAR2(100),
	old_cod_dip INT,
	cod_dip INT,
	old_cod_uop VARCHAR2(2),
	cod_uop VARCHAR2(2),
	old_dt_ini DATE,
	dt_ini DATE,
	old_dt_end DATE,
	dt_end DATE,
	dt_cre DATE,
	old_id_utenti INT,
	id_utenti INT,
	old_dt_mod DATE,
	dt_mod DATE
);

CREATE OR REPLACE TRIGGER tr_cmp_moduli_log
FOR INSERT OR UPDATE OR DELETE
ON moduli 
COMPOUND TRIGGER 
	l_dml_log moduli_log.dml_log%TYPE; 
	l_old_des_mod moduli.des_mod%TYPE;
	l_old_cod_dip moduli.cod_dip%TYPE;
	l_old_cod_uop moduli.cod_uop%TYPE;
	l_old_dt_ini moduli.dt_ini%TYPE;
	l_old_dt_end moduli.dt_end%TYPE;
	l_old_id_utenti moduli.id_utenti%TYPE;
	l_old_dt_mod moduli.dt_mod%TYPE;
BEFORE EACH ROW IS
	BEGIN
		IF DELETING THEN
			l_dml_log := 'D';
			DBMS_OUTPUT.PUT_LINE('Cancellazione ...');
			INSERT INTO moduli_log(id_log, data_log, dml_log, cod_mod, des_mod, cod_dip, cod_uop, dt_ini, dt_end, dt_cre, id_utenti, dt_mod)
			VALUES(pkg_moduli_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :OLD.cod_mod, :OLD.des_mod, :OLD.cod_dip, :OLD.cod_uop, :OLD.dt_ini, :OLD.dt_end, :OLD.dt_cre, 
				:OLD.id_utenti, :OLD.dt_mod);
		END IF;
	END BEFORE EACH ROW;
AFTER EACH ROW IS
	BEGIN
		IF INSERTING THEN
			DBMS_OUTPUT.PUT_LINE('Inserimento ...');
			l_dml_log := 'I';
			INSERT INTO moduli_log(id_log, data_log, dml_log, cod_mod, des_mod, cod_dip, cod_uop, dt_ini, dt_end, dt_cre, id_utenti, dt_mod)
			VALUES(pkg_moduli_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :NEW.cod_mod, :NEW.des_mod, :NEW.cod_dip, :NEW.cod_uop, :NEW.dt_ini, :NEW.dt_end, :NEW.dt_cre, 
				:NEW.id_utenti, :NEW.dt_mod);
		END IF;
		IF UPDATING THEN
			DBMS_OUTPUT.PUT_LINE('Aggiornamento ...');
			l_dml_log := 'U';
			IF :NEW.des_mod != :OLD.des_mod THEN
				l_old_des_mod := :OLD.des_mod;
			END IF;
			IF :NEW.cod_dip != :OLD.cod_dip THEN
				l_old_cod_dip := :OLD.cod_dip;
			END IF;
			IF :NEW.cod_uop != :OLD.cod_uop THEN
				l_old_cod_uop := :OLD.cod_uop;
			END IF;
			IF :NEW.dt_ini != :OLD.dt_ini THEN
				l_old_dt_ini := :OLD.dt_ini;
			END IF;
			IF :NEW.dt_end != :OLD.dt_end THEN
				l_old_dt_end := :OLD.dt_end;
			END IF;
			IF :NEW.id_utenti != :OLD.id_utenti THEN
				l_old_id_utenti := :OLD.id_utenti;
			END IF;
			IF :NEW.dt_mod != :OLD.dt_mod THEN
				l_old_dt_mod := :OLD.dt_mod;
			END IF;
			INSERT INTO moduli_log(id_log, data_log, dml_log, cod_mod, old_des_mod, des_mod, old_cod_dip, cod_dip, old_cod_uop, cod_uop, old_dt_ini, dt_ini, 
				old_dt_end, dt_end, dt_cre, old_id_utenti, id_utenti, old_dt_mod, dt_mod) 
			VALUES(pkg_moduli_mgmt.fnc_id_log(), SYSDATE, l_dml_log, :NEW.cod_mod, l_old_des_mod, :NEW.des_mod, l_old_cod_dip, :NEW.cod_dip, l_old_cod_uop, 
				:NEW.cod_uop, l_old_dt_ini, :NEW.dt_ini, l_old_dt_end, :NEW.dt_end, :NEW.dt_cre, l_old_id_utenti, :NEW.id_utenti, l_old_dt_mod, :NEW.dt_mod);
		END IF;
	END AFTER EACH ROW;

END tr_cmp_moduli_log;


CREATE OR REPLACE PACKAGE pkg_moduli_mgmt AS -- uso CURSORE invece di ARRAY. dovrei usare un RECORD?
		
	g_count INT;

	TYPE mod_aa IS TABLE OF moduli%ROWTYPE INDEX BY BINARY_INTEGER;
	g_mod_aa mod_aa;

	PROCEDURE pcd_inserisci(p_cod moduli.cod_mod%TYPE, p_des moduli.des_mod%TYPE, p_coddip moduli.cod_dip%TYPE, p_coduop moduli.cod_uop%TYPE, 
		p_dtini moduli.dt_ini%TYPE, p_dtend moduli.dt_end%TYPE, p_dtcre moduli.dt_cre%TYPE, p_idut moduli.id_utenti%TYPE, p_dtmod moduli.dt_mod%TYPE, 
			p_out OUT INT);
		
	PROCEDURE pcd_aggiorna(p_cod moduli.cod_mod%TYPE, p_des moduli.des_mod%TYPE, p_coddip moduli.cod_dip%TYPE, p_coduop moduli.cod_uop%TYPE, 
		p_dtini moduli.dt_ini%TYPE, p_dtend moduli.dt_end%TYPE, p_dtcre moduli.dt_cre%TYPE, p_idut moduli.id_utenti%TYPE, p_dtmod moduli.dt_mod%TYPE, 
			p_out OUT INT);

	PROCEDURE pcd_elimina(p_cod moduli.cod_mod%TYPE, p_out OUT INT);
	
	PROCEDURE pcd_get_selected(p_cod moduli.cod_mod%TYPE, p_out_cod OUT VARCHAR2, p_out_des OUT VARCHAR2, p_out_coddip OUT INT, p_out_coduop OUT VARCHAR2,
		p_out_dtini OUT CHAR, p_out_dtend OUT CHAR, p_out_dtcre OUT CHAR, p_out_idutenti OUT INT, p_out_dtmod OUT CHAR);
	
	FUNCTION fnc_id_log RETURN moduli.cod_mod%TYPE;

	/* FUNCTION fnc_trova_aa(p_des moduli.des_osp%TYPE, p_out OUT INT) RETURN osp_aa;  */
	
END pkg_moduli_mgmt;

CREATE OR REPLACE PACKAGE BODY pkg_moduli_mgmt AS

	PROCEDURE pcd_inserisci(
		p_cod moduli.cod_mod%TYPE, 
		p_des moduli.des_mod%TYPE, 
		p_coddip moduli.cod_dip%TYPE, 
		p_coduop moduli.cod_uop%TYPE, 
		p_dtini moduli.dt_ini%TYPE, 
		p_dtend moduli.dt_end%TYPE, 
		p_dtcre moduli.dt_cre%TYPE, 
		p_idut moduli.id_utenti%TYPE, 
		p_dtmod moduli.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_mod) INTO g_count	-- VEDERE VALIDAZIONE PER P_COD E P_DES
			FROM moduli 
		WHERE cod_mod = UPPER(p_cod) AND des_mod = UPPER(p_des);
		IF g_count > 0 THEN
			DBMS_OUTPUT.PUT_LINE('Codice e Descrizione già presenti a db. MODULO non inserito.');
		ELSE
			SELECT COUNT(cod_mod) INTO g_count
				FROM moduli 
			WHERE cod_mod = UPPER(p_cod);
			IF g_count > 0 THEN
				DBMS_OUTPUT.PUT_LINE('Codice ' || UPPER(p_cod) || ' già presente a db. Non inserito');
			ELSE
				SELECT COUNT(cod_mod) INTO g_count
					FROM moduli 
				WHERE des_mod = UPPER(p_des);
				IF g_count > 0 THEN
					DBMS_OUTPUT.PUT_LINE('Descrizione ' || UPPER(p_des) || ' già presente a db. Non inserito');
				ELSE
					INSERT INTO moduli(cod_mod, des_mod, cod_dip, cod_uop, dt_ini, dt_end, dt_cre, id_utenti, dt_mod) 
					VALUES (UPPER(p_cod), UPPER(p_des), p_coddip, p_coduop, p_dtini, p_dtend, p_dtcre, p_idut, NULL);
					COMMIT;
					p_out := 1;
					DBMS_OUTPUT.PUT_LINE('Codice MODULO ' || p_cod);
					DBMS_OUTPUT.PUT_LINE('Descrizione MODULO: ' || p_des);
				END IF;
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE; -- moved under ROLLBACK
	END pcd_inserisci;
	
	PROCEDURE pcd_aggiorna(
		p_cod moduli.cod_mod%TYPE,
		p_des moduli.des_mod%TYPE, 
		p_coddip moduli.cod_dip%TYPE, 
		p_coduop moduli.cod_uop%TYPE, 
		p_dtini moduli.dt_ini%TYPE, 
		p_dtend moduli.dt_end%TYPE, 
		p_dtcre moduli.dt_cre%TYPE, 
		p_idut moduli.id_utenti%TYPE, 
		p_dtmod moduli.dt_mod%TYPE, 
		p_out OUT INT
	)AS
	BEGIN
		SELECT COUNT(cod_mod) INTO g_count 
			FROM moduli
		WHERE cod_mod = UPPER(p_cod);
		IF g_count > 0 THEN
			UPDATE moduli 
				SET des_mod = UPPER(p_des), cod_dip = p_coddip, cod_uop = UPPER(p_coduop), dt_ini = p_dtini, dt_end = p_dtend, dt_cre = p_dtcre, id_utenti = p_idut, 
					dt_mod = p_dtmod     
			WHERE cod_mod = UPPER(p_cod);
			SELECT COUNT(cod_mod) INTO g_count 
				FROM moduli 
			WHERE des_mod = UPPER(p_des);
			IF g_count > 1 THEN
				DBMS_OUTPUT.PUT_LINE('MODULO con des_mod ' || UPPER(p_des) || ' già presente. Non aggiornato.');
				ROLLBACK;
			ELSE
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('UNITA OPERATIVA con des_mod ' || UPPER(p_des) || ' aggiornata.');
			END IF;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_aggiorna;
	
	PROCEDURE pcd_elimina(
		p_cod moduli.cod_mod%TYPE, 
		p_out OUT INT
	)IS
	BEGIN
		SELECT COUNT(cod_mod) INTO g_count 
			FROM moduli 
		WHERE cod_mod = UPPER(p_cod);
		IF g_count > 0 THEN
			DELETE FROM moduli 
				WHERE cod_mod = UPPER(p_cod);
				COMMIT;
				p_out := 1;
				DBMS_OUTPUT.PUT_LINE('MODULO con CODICE ' || UPPER(p_cod) || ' eliminato con successo.');
		ELSE
			DBMS_OUTPUT.PUT_LINE('MODULO con codice ' || UPPER(p_cod) || ' non trovato. RIPROVARE.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END pcd_elimina;
	
	PROCEDURE pcd_get_selected(
		p_cod moduli.cod_mod%TYPE, 
		p_out_cod OUT VARCHAR2, 
		p_out_des OUT VARCHAR2, 
		p_out_coddip OUT INT,
		p_out_coduop OUT VARCHAR2,
		p_out_dtini OUT CHAR, 
		p_out_dtend OUT CHAR, 
		p_out_dtcre OUT CHAR, 
		p_out_idutenti OUT INT, 
		p_out_dtmod OUT CHAR
	)AS
	BEGIN
		SELECT moduli.* BULK COLLECT INTO g_mod_aa -- vedere bulk collect (necessario)
			FROM moduli 
		WHERE cod_mod = UPPER(p_cod);
		FOR i IN g_mod_aa.FIRST .. g_mod_aa.LAST LOOP
			p_out_cod := g_mod_aa(i).cod_mod;
			p_out_des := g_mod_aa(i).des_mod;
			p_out_coddip := g_mod_aa(i).cod_dip;
			p_out_coduop := g_mod_aa(i).cod_uop;
			p_out_dtini := TO_CHAR(g_mod_aa(i).dt_ini, 'DD/MM/YYYY');
			p_out_dtend := TO_CHAR(g_mod_aa(i).dt_end, 'DD/MM/YYYY');
			p_out_dtcre := TO_CHAR(g_mod_aa(i).dt_cre, 'DD/MM/YYYY');
			p_out_idutenti := g_mod_aa(i).id_utenti;
			p_out_dtmod := TO_CHAR(g_mod_aa(i).dt_mod, 'DD/MM/YYYY');
		END LOOP;
	END pcd_get_selected;
	
	FUNCTION fnc_id_log RETURN moduli.cod_mod%TYPE AS
	BEGIN
		SELECT MAX(id_log) + 1 INTO g_count FROM moduli_log;
		IF g_count IS NULL THEN
			g_count := 40000001;
		END IF;
		RETURN g_count;
	END fnc_id_log;
	
	/*FUNCTION fnc_trova_aa(
		p_des moduli.des_osp%TYPE,
		p_out OUT INT
	) RETURN osp_aa AS
	BEGIN
		SELECT COUNT(cod_dip) INTO g_count FROM moduli WHERE des_osp LIKE p_des;
		IF g_count > 0 THEN
			p_out := 1;
			SELECT moduli.* BULK COLLECT INTO g_osp_aa FROM moduli WHERE des_osp LIKE p_des;
			FOR i IN 1 .. g_osp_aa.COUNT LOOP
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).cod_dip);
				DBMS_OUTPUT.PUT_LINE(g_osp_aa(i).des_osp);
			END LOOP;
			RETURN g_osp_aa;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nessun dato trovato con des_mod o parte di des_mod ''' || UPPER(p_des) || '''.');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE(SQLERRM);
				DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			ROLLBACK;
			RAISE;
	END fnc_trova_aa; */
	
END pkg_moduli_mgmt;


-- inserisco modulo

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(46, 'casa di salute ortopedia II', 20001, 'B1', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;

-- lo inserisco di nuovo e mi da errore su cod e des_mod

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(46, 'casa di salute ortopedia II', 20001, 'B1', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;
	
-- inserisco modulo con stesso codice ma des diversa. errore su cod

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(46, 'casa di salute ortopedia II verifica ', 20001, 'B1', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;

-- inserisco modulo con stessa des ma cod diverso. errore su des

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(17, 'casa di salute ortopedia II', 20001, 'B1', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;
	
-- ne inserisco altri

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(76, 'ortopedia day hospital', 20001, '05', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_inserisci(50, 'ortopedia day hospital micone', 20001, '05', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;

-- aggiorno senza cambiare i dati 

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_aggiorna(50, 'ortopedia day hospital micone', 20001, '05', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600002, NULL, l_out);
	END;

-- aggiorno cambiando i dati. il trigger funziona

	DECLARE
		l_out INT;
	BEGIN
		pkg_moduli_mgmt.pcd_aggiorna(50, 'ortopedia day hospital micone agg', 10001, '05', '27-MAG-2021', '31-DIC-2099', '27-MAG-2021', 600001, NULL, l_out);
	END;
	
-- trova selezionato

DECLARE
	l_out_cod INT; 
	l_out_des VARCHAR2(250); 
	l_out_coddip INT;
	l_out_coduop VARCHAR2(5);
	l_out_dtini CHAR(10); 
	l_out_dtend CHAR(10); 
	l_out_dtcre CHAR(10); 
	l_out_idutenti INT; 
	l_out_dtmod CHAR(10);
	BEGIN
		pkg_moduli_mgmt.pcd_get_selected(1, l_out_cod, l_out_des, l_out_coddip, l_out_coduop, l_out_dtini, l_out_dtend, l_out_dtcre, l_out_idutenti, l_out_dtmod);
	END;