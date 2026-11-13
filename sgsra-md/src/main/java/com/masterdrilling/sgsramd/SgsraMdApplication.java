package com.masterdrilling.sgsramd;

import org.springframework.scheduling.annotation.EnableScheduling;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableScheduling
public class SgsraMdApplication {

	public static void main(String[] args) {
		SpringApplication.run(SgsraMdApplication.class, args);
	}

}
