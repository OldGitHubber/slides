-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema student_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema student_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `student_db` DEFAULT CHARACTER SET utf8 ;
USE `student_db` ;

-- -----------------------------------------------------
-- Table `student_db`.`student`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `student_db`.`student` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `marital-status` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `student_db`.`course`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `student_db`.`course` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `fee` DECIMAL(10,2) NOT NULL,
  `qualification` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `student_db`.`tutor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `student_db`.`tutor` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(45) NULL,
  `name` VARCHAR(45) NOT NULL,
  `course_id` INT NOT NULL,
  PRIMARY KEY (`id`, `course_id`),
  INDEX `fk_tutor_course1_idx` (`course_id` ASC) VISIBLE,
  CONSTRAINT `fk_tutor_course1`
    FOREIGN KEY (`course_id`)
    REFERENCES `student_db`.`course` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `student_db`.`student_has_course`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `student_db`.`student_has_course` (
  `student_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `grade` VARCHAR(3) NULL,
  PRIMARY KEY (`student_id`, `course_id`),
  INDEX `fk_student_has_course_course1_idx` (`course_id` ASC) VISIBLE,
  INDEX `fk_student_has_course_student_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `fk_student_has_course_student`
    FOREIGN KEY (`student_id`)
    REFERENCES `student_db`.`student` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_student_has_course_course1`
    FOREIGN KEY (`course_id`)
    REFERENCES `student_db`.`course` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
