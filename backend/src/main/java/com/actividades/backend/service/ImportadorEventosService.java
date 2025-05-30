package com.actividades.backend.service;

import com.actividades.backend.model.Categoria;
import com.actividades.backend.model.Ciudad;
import com.actividades.backend.model.Evento;
import com.actividades.backend.repository.CategoriaRepository;
import com.actividades.backend.repository.CiudadRepository;
import com.actividades.backend.repository.EventoRepository;
import com.actividades.backend.util.Formato;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.csv.*;
import org.apache.commons.text.StringEscapeUtils;
import org.springframework.boot.CommandLineRunner;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Stream;

@Service
public class ImportadorEventosService implements CommandLineRunner {

    private final EventoRepository eventoRepository;
    private final CategoriaRepository categoriaRepository;
    private final CiudadRepository ciudadRepository;

    public ImportadorEventosService(EventoRepository eventoRepository,
                                    CategoriaRepository categoriaRepository,
                                    CiudadRepository ciudadRepository) {
        this.eventoRepository = eventoRepository;
        this.categoriaRepository = categoriaRepository;
        this.ciudadRepository = ciudadRepository;
    }

    private static final Map<String, FuenteEvento> fuentes = Map.of(
            "madrid", new FuenteEvento(
                    "https://datos.madrid.es/egob/catalogo/206974-0-agenda-eventos-culturales-100.csv",
                    Formato.CSV),
            "barcelona", new FuenteEvento(
                    "https://opendata-ajuntament.barcelona.cat/data/es/dataset/agenda-cultural/resource/59b9c807-f6c1-4c10-ac51-1ace65485079/download/opendatabcn_agenda-cultural.json",
                    Formato.JSON)
    );

    private static final Map<String, String> creditos = Map.of(
            "madrid", "📌 Datos proporcionados por el Ayuntamiento de Madrid.",
            "barcelona", "📌 Datos proporcionados por el Ayuntamiento de Barcelona."
    );

    @Override
    public void run(String... args) {
        importarPorCiudad("madrid");
        importarPorCiudad("barcelona");
    }

    @Scheduled(cron = "0 0 4 * * *")
    public void importarDiario() {
        importarPorCiudad("madrid");
        importarPorCiudad("barcelona");
    }

    public void importarPorCiudad(String ciudadNombre) {
        var fuente = fuentes.get(ciudadNombre.toLowerCase());
        if (fuente == null) throw new IllegalArgumentException("Ciudad no soportada: " + ciudadNombre);
        importarEventosDesdeURL(ciudadNombre, fuente.url(), fuente.formato());
    }

    public void importarEventosDesdeURL(String ciudadNombre, String url, Formato formato) {
        try {
            int total = 0, importados = 0;
            InputStream input = new URL(url).openStream();

            Ciudad ciudad = ciudadRepository.findByNombreIgnoreCase(ciudadNombre)
                    .orElseGet(() -> ciudadRepository.save(new Ciudad(capitalize(ciudadNombre))));

            if (formato == Formato.CSV) {
                Reader lector = new InputStreamReader(input, StandardCharsets.ISO_8859_1);
                CSVParser csv = CSVFormat.DEFAULT
                        .withDelimiter(';')
                        .withFirstRecordAsHeader()
                        .withIgnoreEmptyLines()
                        .parse(lector);

                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

                for (CSVRecord fila : csv) {
                    total++;
                    String tituloCrudo = fila.get("TITULO");
                    String descripcionCrudo = fila.get("DESCRIPCION");

                    String titulo = limpiar(tituloCrudo);
                    String descripcion = limpiar(descripcionCrudo);
                    String categoriaNombre = fila.isMapped("TIPO") ? limpiar(fila.get("TIPO")) : "General";
                    String fechaFinStr = fila.get("FECHA-FIN");
                    String urlInscripcion = fila.isMapped("CONTENT-URL") ? limpiar(fila.get("CONTENT-URL")) : null;


                    Date fechaFin = null;
                    try {
                        fechaFin = sdf.parse(fechaFinStr);
                    } catch (Exception e) {
                        System.err.println("Fecha inválida (Madrid): " + fechaFinStr);
                    }

                    if (!titulo.isBlank()) {
                        String textoCredito = creditos.get(ciudadNombre.toLowerCase());
                        if (textoCredito != null) {
                            descripcion += "\n\n" + textoCredito;
                        }

                        Categoria categoria = obtenerOCrearCategoria(categoriaNombre);
                        Evento evento = new Evento(titulo, ciudad, descripcion, categoria, fechaFin, urlInscripcion);
                        eventoRepository.save(evento);
                        importados++;
                    }
                }

            } else if (formato == Formato.JSON) {
                ObjectMapper mapper = new ObjectMapper();
                JsonNode eventos = mapper.readTree(input);

                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                for (JsonNode nodo : eventos) {
                    total++;
                    String titulo = limpiar(nodo.path("name").asText().replaceAll("'", "’"));
                    String barrio = nodo.path("addresses_neighborhood_name").asText();
                    String calle = nodo.path("addresses_road_name").asText();
                    String numero = nodo.path("addresses_start_street_number").asText();

                    String direccion = Stream.of(barrio, calle, numero)
                            .filter(s -> s != null && !s.isBlank())
                            .reduce((a, b) -> a + ", " + b)
                            .orElse("No especificado");

                    String descripcion = limpiar("Lugar: " + direccion);
                    String urlInscripcion = nodo.path("url").asText(null);
                    String fechaFinStr = nodo.path("end_date").asText();
                    Date fechaFin = null;

                    try {
                        fechaFin = sdf.parse(fechaFinStr);
                    } catch (Exception e) {
                        System.err.println("Fecha inválida (Barcelona): " + fechaFinStr);
                    }

                    if (!titulo.isBlank()) {
                        String textoCredito = creditos.get(ciudadNombre.toLowerCase());
                        if (textoCredito != null) {
                            descripcion += "\n\n" + textoCredito;
                        }

                        Categoria categoria = obtenerOCrearCategoria("General");
                        Evento evento = new Evento(titulo, ciudad, descripcion, categoria, fechaFin, urlInscripcion);
                        eventoRepository.save(evento);
                        importados++;
                    }
                }
            }

            System.out.printf("✅ Importados %d de %d eventos desde %s.%n", importados, total, ciudadNombre);

        } catch (Exception e) {
            System.err.println("Error importando eventos de " + ciudadNombre + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    private Categoria obtenerOCrearCategoria(String nombre) {
        if (nombre == null || nombre.isBlank()) {
            nombre = "General";
        }
        String finalNombre = nombre.trim();
        return categoriaRepository.findByNombreIgnoreCase(finalNombre)
                .orElseGet(() -> categoriaRepository.save(new Categoria(finalNombre)));
    }

    private String limpiar(String texto) {
        if (texto == null || texto.isBlank()) return "Sin información";
        return StringEscapeUtils.unescapeHtml4(texto)
                .replaceAll("[\\r\\n\\t]+", " ")
                .replaceAll("\\s{2,}", " ")
                .trim();
    }

    private String capitalize(String s) {
        if (s == null || s.isBlank()) return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }

    private record FuenteEvento(String url, Formato formato) {}
}