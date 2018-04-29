require_relative './utils/title_case'

class ExportComposer
    attr_reader :directory_name

    def initialize(directory_name)
        @directory_name = directory_name
    end

    def compose
        files = Dir[@directory_name + "/*"]

        import_data = files.map { |file_path| compose_import(file_path) }

        grouped_data = group_import_texts(import_data)

        text = aggregate_text(grouped_data)

        IO.write(@directory_name + '/index.js', text)
    end

    private
    def aggregate_text(grouped_data)
        text = ''
        grouped_data[:import_texts].each { |import_text|
            text = text + import_text + ";\n"
        }

        text = text + "\n" + 'module.exports = ['

        grouped_data[:import_names].each { |import_name|
            text = text + "\n" + "  #{import_name},"
        }

        text + "\n" + '];' + "\n"
    end

    def compose_import(file_path)
        matches = file_path.match(/([\w\-]*)\.js$/)
        driver_name = matches.captures[0]
        import_name = title_case(driver_name)
        import_text = "import #{import_name} from './#{driver_name}'"

        {
            import_text: import_text,
            import_name: import_name,
        }
    end

    def group_import_texts(import_data)
        import_texts = []
        import_names = []

        import_data.each { |import|
            import_texts << import[:import_text]
            import_names << import[:import_name]
        }
        
        {
            import_names: import_names,
            import_texts: import_texts,
        }
    end
end
