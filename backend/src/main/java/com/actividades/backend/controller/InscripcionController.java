package com.actividades.backend.controller;

import com.actividades.backend.model.Evento;
import com.actividades.backend.model.Usuario;
import com.actividades.backend.repository.EventoRepository;
import com.actividades.backend.repository.UsuarioRepository;
import com.actividades.backend.service.InscripcionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inscripciones")
@CrossOrigin(origins = "*")
public class InscripcionController {

    private final InscripcionService inscripcionService;
    private final UsuarioRepository usuarioRepository;
    private final EventoRepository eventoRepository;

    public InscripcionController(InscripcionService inscripcionService,
                                 UsuarioRepository usuarioRepository,
                                 EventoRepository eventoRepository) {
        this.inscripcionService = inscripcionService;
        this.usuarioRepository = usuarioRepository;
        this.eventoRepository = eventoRepository;
    }

    @PostMapping
    public ResponseEntity<?> inscribirse(@RequestParam Long usuarioId, @RequestParam Long eventoId) {
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Evento evento = eventoRepository.findById(eventoId)
                .orElseThrow(() -> new RuntimeException("Evento no encontrado"));

        inscripcionService.inscribir(usuario, evento);
        return ResponseEntity.ok("Inscripción realizada con éxito.");
    }
}