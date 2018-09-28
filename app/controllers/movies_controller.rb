class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    # Miten huomata tuleeko käyttäjä ekaa kertaa sivulle? => Jos session[:ratings], session[:sort_column] ja params[:ratings], params[:sort_column] ovat tyhjiä!
    first_visit = session[:ratings].nil? and session[:sort_column].nil? and params[:ratings].nil? and params[:sort_column].nil?
    if first_visit
      puts "Eka kerta"
    end
    
    from_other_page = params[:ratings].nil? and params[:sort_column].nil? and (not first_visit)
    if from_other_page 
      puts "Muulta sivulta"
      redirect_to movies_path(:ratings => session[:ratings], :sort_column => session[:sort_column])
    else
      if session[:ratings] != params[:ratings]
        session[:ratings] = params[:ratings]
        @selected_ratings = session[:ratings]
      else
        @selected_ratings = session[:ratings]
      end
      if session[:sort_column] != params[:sort_column]
        session[:sort_column] = params[:sort_column]
        @sort_column = session[:sort_column]
      else 
        @sort_column = session[:sort_column]
      end
    end
    
    
    
    # if not session[:sort_column].nil? and session[:sort_column].length != 0
    #   @sort_column = session[:sort_column]
    # else 
    #   @sort_column = params[:sort_column]
    # end
    # puts "Selected Ratings: #{@selected_ratings}"
    # puts "Session ratings: #{session[:ratings]} and params ratings: #{params[:ratings]}"
    # if @sort_column == 'title'
    #   @title_class = 'hilite'
    #   @release_date_class = ''
    # elsif @sort_column == 'release_date'
    #   @title_class = ''
    #   @release_date_class = 'hilite'
    # end
    # session[:ratings] = @selected_ratings
    # session[:sort_column] = @sort_column
  
    # # What is the right condition to redirect?
    # if @selected_ratings != params[:ratings]
    #   puts "About to redirect to /movies"
    #   #redirect_to movies_path(:ratings => session[:ratings], :sort_column => session[:sort_column])
    # end
    
    # #if not (ratings_equal and sort_equal)
    #   #puts "about to redirect"
    #   #redirect_to movies_path(:ratings => session[:ratings], :sort_column => session[:sort_column])
    # #end
    
    
    @movies = Movie.order(@sort_column).where("rating IN (?)", @selected_ratings != nil ? @selected_ratings.keys : @all_ratings)
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
