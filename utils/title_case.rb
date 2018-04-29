def title_case(str)
    str.gsub(/\w+/, &:capitalize).gsub(/\-/, '')
end
