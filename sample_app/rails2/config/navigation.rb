SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :books, 'Books', root_path do |books|
      books.item :fiction, 'Fiction', fiction_books_path
      books.item :history, 'History', history_books_path
      books.item :sports, 'Sports', sports_books_path
    end
    primary.item :music, 'Music', musics_path do |music|
      music.item :rock, 'Rock', rock_musics_path
      music.item :pop, 'Pop', pop_musics_path
      music.item :alternative, 'Alternative', alternative_musics_path
    end
    primary.item :dvds, 'Dvds', dvds_path do |dvds|
      dvds.item :drama, 'Drama', drama_dvds_path
      dvds.item :action, 'Action', action_dvds_path
      dvds.item :comedy, 'Comedy', comedy_dvds_path
    end    
  end
end