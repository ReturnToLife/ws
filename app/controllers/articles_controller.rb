# -*- coding: utf-8 -*-
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :if => Proc.new { |c| c.request.format == 'application/json' }
  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all
    array = []
    @articles.each do |article|
      hash = {}
      article.attribute_names.each {|var| hash[var] = article.instance_variable_get("@attributes")[var] }
      user = User.find(article.user_id)
      hash["author_name"] = user.login
      array.append(hash)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: array }
    end
  end

  def filterbylogin
    @login = params[:login]
    if (@login != nil)
      @user = User.find_by_login(@login)
      @articles = Article.find_all_by_user_id(@user.id)
      
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @articles }
      end
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])
    array = []
    @article.acomments.each do |comment|
      user = User.find(comment.user_id)
      array.append({:id => comment.id,:user_login => user.login, :body => comment.body})
    end
    user = User.find(@article.user_id)
    res = {:article => @article, :comments => array, :author_name => user.login}
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: res}
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.json
  def create
    @user = User.find_by_authentication_token(params[:auth_token])
    @article = Article.new.from_json(params[:article])
    @article.publication_date = Time.now
    @article.user_id = @user.id
    @article.score = Score.create(:score_pos => 0, :score_neg => 0)
      respond_to do |format|
      if @article.save
        @author = Author.create(:article_id => @article.id, :user_id => @user.id, :job => "author")
        @author.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def pdestroy
    @user = User.find_by_authentication_token(params[:auth_token])
    puts "here"
    puts @user.id
    @author = Author.find_by_user_id_and_article_id(@user.id, params[:id])
    if (@author != nil)
      @article = Article.find(params[:id])
      @article.destroy   
      respond_to do |format|
        format.html { redirect_to articles_url }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render json: "error" }
        format.json { render json: "error" }
      end  
    end
  end
end
