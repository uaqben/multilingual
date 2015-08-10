module Jekyll
  class URL
    def generate_url(template)
      @placeholders.inject(template) do |result, token|
        break result if result.index(':').nil?
        if token.last.nil?
          result.gsub(/\/:#{token.first}/, '')
        else
          result.gsub(/:#{token.first}/, self.class.escape_path(token.last))
        end
      end
    end
  end

  class Site
    def languages
      Octopress::Multilingual.languages
    end

    def posts_by_language(lang=nil)
      Octopress::Multilingual.posts_by_language(lang)
    end

    def pages_by_language(lang=nil)
      Octopress::Multilingual.pages_by_language(lang)
    end

    def articles_by_language(lang=nil)
      Octopress::Multilingual.articles_by_language(lang)
    end

    def linkposts_by_language(lang=nil)
      Octopress::Multilingual.linkposts_by_language(lang)
    end

    def categories_by_language(lang=nil)
      Octopress::Multilingual.categories_by_language(lang)
    end

    def tags_by_language(lang=nil)
      Octopress::Multilingual.tags_by_language(lang)
    end
  end

  class Document
    def lang
      if data['lang']
        data['lang'].downcase
      end
    end
  end

  class Page
    alias :permalink_orig :permalink

    def lang
      if lang = data['lang']
        data['lang'] = site.config['lang'] if lang == 'default'
        data['lang'].downcase
      end
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_pages[data['translation_id']].reject {|p| p == self }
      end
    end

    def permalink
      if permalink = permalink_orig
        if lang
          data['permalink'].sub!(':lang', lang)
          permalink.sub!(':lang', lang)
        else
          data['permalink'].sub!('/:lang', '')
          permalink.sub!('/:lang', '')
        end
      end

      permalink
    end
  end

  class Post
    alias :template_orig :template
    alias :url_placeholders_orig :url_placeholders

    def template
      template = template_orig

      if self.site.config['lang']
        if [:pretty, :none, :date, :ordinal].include? site.permalink_style
          template = File.join('/:lang', template)
        end
      end

      template
    end

    def translated
      data['translation_id'] && !translations.empty?
    end

    def translations
      if data['translation_id']
        @translations ||= Octopress::Multilingual.translated_posts[data['translation_id']].reject {|p| p == self}
      end
    end

    def lang
      if data['lang']
        data['lang'].downcase
      end
    end

    def crosspost_languages
      data['lang_crosspost']
    end

    def url_placeholders
      url_placeholders_orig.merge({
        :lang => lang
      })
    end

    def next
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language(language)

      pos = posts.index {|post| post.equal?(self) }
      if pos && pos < posts.length - 1
        posts[pos + 1]
      else
        nil
      end
    end

    def previous
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language(language)

      pos = posts.index {|post| post.equal?(self) }
      if pos && pos > 0
        posts[pos - 1]
      else
        nil
      end
    end
  end
end
