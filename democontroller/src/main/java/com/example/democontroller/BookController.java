package com.example.democontroller;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api")
public class BookController {

    @GetMapping("/books")
    public List<Book> getBooks() {
        return Arrays.asList(
                new Book(2025, "J2EE", "Huy Cuong")
        );
    }
}