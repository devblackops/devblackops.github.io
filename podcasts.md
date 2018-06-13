---
layout: page
title: Podcasts
description: Podcasts
permalink: /podcasts/
---

<div class="main-post-list">
  <ol class="post-list">
    {% for item in site.podcasts %}
      <li>
        <!-- Thumbnail -->
        {% if item.thumbnail %}
          <a href="{{ item.link }}" title="{{ item.title }}">
            <img class="project-thumbnail" style="max-width:75px; margin-right: 20px;" src="{{ site.url }}/images/{{ item.thumbnail }}"
            alt="{{ item.title }} thumbnail">
          </a>
        {% endif %}

        <!-- Excerpt -->
        <p class="excerpt">
          <h1 class="post-list__post-title post-title">
            <a target="_blank" href="{{ item.link }}" title="{{ item.title }}">{{ item.title }}</a>
          </h1>
          {{ item.short-description | remove: '<p>' | remove: '</p>' }}
        </p>

        <!-- Post meta -->
        <div class="post-meta"></div>
        <p>
          <a target="_blank" href="{{ item.link }}" class="btn" role="button">
            <i class="icon icon-link"></i>
            &nbsp;Listen
          </a>
        </p>

        <hr class="post-list__divider" style="width: 100%;">
      </li>
    {% endfor %}
  </ol>
</div>