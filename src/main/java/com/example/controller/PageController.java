package com.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PageController {
    
    @RequestMapping("/")
    public String index() {
        return "page1"; // Redirect to page1.jsp
    }
    
    @RequestMapping("/page1")
    public String page1() {
        return "page1";
    }
    
    @RequestMapping("/page2")
    public String page2() {
        return "page2";
    }
}
