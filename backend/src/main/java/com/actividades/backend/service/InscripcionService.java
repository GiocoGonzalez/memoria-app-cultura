package com.actividades.backend.service;

import com.actividades.backend.model.Evento;
import com.actividades.backend.model.Inscripcion;
import com.actividades.backend.model.Usuario;
import com.actividades.backend.repository.InscripcionRepository;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class InscripcionService {

    private final InscripcionRepository inscripcionRepository;

    public InscripcionService(InscripcionRepository inscripcionRepository) {
        this.inscripcionRepository = inscripcionRepository;
    }

    public void inscribir(Usuario usuario, Evento evento) {
        if (inscripcionRepository.existsByUsuarioAndEvento(usuario, evento)) {
            throw new RuntimeException("El usuario ya está inscrito en este evento.");
        }

        Inscripcion inscripcion = new Inscripcion(usuario, evento, new Date());
        inscripcionRepository.save(inscripcion);
    }

    public List<Inscripcion> obtenerInscripcionesDeUsuario(Usuario usuario) {
        return inscripcionRepository.findByUsuario(usuario);
    }
}