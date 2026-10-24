package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

// DAO para gestion de autenticacion y perfiles corporativos (RF01, RF04, RF06)
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByCorreoCorporativo(String correoCorporativo);

    Optional<Usuario> findByDni(String dni);

    boolean existsByCorreoCorporativo(String correoCorporativo);

    boolean existsByDni(String dni);

    Page<Usuario> findByRol(RolUsuario rol, Pageable pageable);

    @Transactional
    @Modifying
    @Query("UPDATE Usuario u SET u.intentosFallidos = u.intentosFallidos + 1 WHERE u.correoCorporativo = :correo")
    void incrementarIntentosFallidos(@Param("correo") String correo);

    @Transactional
    @Modifying
    @Query("UPDATE Usuario u SET u.intentosFallidos = 0 WHERE u.correoCorporativo = :correo")
    void reiniciarIntentosFallidos(@Param("correo") String correo);

    @Query("SELECT u.rol FROM Usuario u WHERE u.idUsuario = :idUsuario")
    Optional<RolUsuario> findRolById(@Param("idUsuario") Long idUsuario);
}