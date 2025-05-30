package com.actividades.backend.controller;

import com.actividades.backend.model.Evento;
import com.actividades.backend.repository.EventoRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/eventos")
@CrossOrigin(origins = "*")
public class EventoController {

    private final EventoRepository eventoRepository;

    public EventoController(EventoRepository eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    // Paginado con filtro por ciudad o categoría
    @GetMapping("/paginado")
    public Page<Evento> listarEventosPaginados(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String filtro
    ) {
        Pageable pageable = PageRequest.of(page, size);
        if (filtro != null && !filtro.isBlank()) {
            return eventoRepository.findByCiudad_NombreIgnoreCaseOrCategoria_NombreIgnoreCase(filtro, filtro, pageable);
        }
        return eventoRepository.findAll(pageable);
    }


    @PostMapping
    public Evento adicionarEvento(@RequestBody Evento evento) {
        return eventoRepository.save(evento);
    }

    @DeleteMapping("/{id}")
    public String deleteEvento(@PathVariable Long id) {
        eventoRepository.deleteById(id);
        return "Evento removido exitosamente";
    }


    @GetMapping("/paginado/ciudad")
    public Page<Evento> listarEventosPorCiudad(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam String ciudad
    ) {
        Pageable pageable = PageRequest.of(page, size);
        return eventoRepository.findByCiudad_NombreIgnoreCase(ciudad, pageable);
    }

    @GetMapping
    public List<Evento> obtenerTodos() {
        return eventoRepository.findAll();
    }

    @GetMapping("/debug-eventos")
    public List<Evento> debugEventos() {
        return eventoRepository.findAll();
    }
}