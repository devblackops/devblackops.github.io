FROM jekyll/jekyll

COPY --chown=jekyll:jekyll Gemfile .
# COPY --chown=jekyll:jekyll Gemfile.lock .

# RUN gem install bundler:1.16.1
RUN bundle clean --force
RUN bundle install --quiet --clean

CMD ["jekyll", "serve", "--watch", "--incremental", "--drafts"]
