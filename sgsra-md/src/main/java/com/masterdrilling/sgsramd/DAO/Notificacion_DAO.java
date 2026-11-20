package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Notificacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface Notificacion_DAO extends JpaRepository<Notificacion, Long> {

    @Query("SELECT n FROM Notificacion n WHERE " +
           "(:dni IS NOT NULL AND n.dniDestinatario = :dni) OR " +
           "(:rol IS NOT NULL AND n.rolDestinatario = :rol) OR " +
           "(n.rolDestinatario = 'TODOS') " +
           "ORDER BY n.fechaCreacion DESC")
    List<Notificacion> listarPorDestinatario(
            @Param("dni") String dni,
            @Param("rol") String rol
    );

    @Query("SELECT n FROM Notificacion n WHERE " +
           "(:dni IS NOT NULL AND n.dniDestinatario = :dni) OR " +
           "(:rol IS NOT NULL AND n.rolDestinatario = :rol) OR " +
           "(n.rolDestinatario = 'TODOS') " +
           "ORDER BY n.fechaCreacion DESC")
    Page<Notificacion> listarPorDestinatarioPaginado(
            @Param("dni") String dni,
            @Param("rol") String rol,
            Pageable pageable
    );

    @Query("SELECT COUNT(n) FROM Notificacion n WHERE " +
           "((:dni IS NOT NULL AND n.dniDestinatario = :dni) OR " +
           " (:rol IS NOT NULL AND n.rolDestinatario = :rol) OR " +
           " (n.rolDestinatario = 'TODOS')) AND n.leida = false")
    long contarNoLeidas(
            @Param("dni") String dni,
            @Param("rol") String rol
    );

    @Modifying
    @Query("UPDATE Notificacion n SET n.leida = true WHERE " +
           "(:dni IS NOT NULL AND n.dniDestinatario = :dni) OR " +
           "(:rol IS NOT NULL AND n.rolDestinatario = :rol) OR " +
           "(n.rolDestinatario = 'TODOS')")
    void marcarTodasComoLeidas(
            @Param("dni") String dni,
            @Param("rol") String rol
    );
}
