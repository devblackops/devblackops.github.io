---
layout: page
title: Projects I'm working on
description: Some of the projects I'm working on
permalink: /projects/
---

<div class="main-post-list">
  <ol class="post-list">
    {% for project in site.projects %}
      <li>

        <!-- Thumbnail -->
        {% if project.thumbnail %}
          <a href="{{ project.project-link }}" title="{{ project.title }}">
            <img class="project-thumbnail" style="max-width:150px; margin-right: 20px;" src="{{ site.url }}/images/{{ project.thumbnail }}"
            alt="{{ project.title }} thumbnail">
          </a>
        {% endif %}

        <!-- Excerpt -->
        <p class="excerpt">
          <h1 class="post-list__post-title post-title">
            <a href="{{ project.project-link }}" title="{{ project.title }}">{{ project.title }}</a>
          </h1>
          {{ project.short-description | remove: '<p>' | remove: '</p>' }}
        </p>

        <!-- Post meta -->
        <div class="post-meta"></div>
        <p>
          <a target="_blank" href="{{ project.project-link }}" class="btn" role="button">
            <i class="icon icon-social-github"></i>
            &nbsp;Project Site
          </a>
        </p>

        <hr class="post-list__divider" style="width: 100%;">
      </li>
    {% endfor %}
  </ol>
</div>


<!-- <div class="row">
  {% for project in site.projects %}
    <div class="col-xs-6 col-sm-6 col-md-6 col-lg-4">
      <div class="thumbnail">      
        <div class="thumbnail-wrapper text-center">        
          <img src="{{ site.url }}/images/{{ project.thumbnail }}" alt="...">
        </div>
        <div class="caption">
          <h3>{{ project.title }}</h3>
          <p>
            {{ project.short-description }}
          </p>
          <p class="text-center">
            <a target="_blank" href="{{ project.project-link }}" class="btn" role="button">
              <i class="icon icon-social-github"></i>
              &nbsp;Project Site
            </a>
          </p>
        </div>
      </div>
    </div>
  {% endfor %}
</div> -->
