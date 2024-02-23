defmodule AmsycWeb.PageController do
  use AmsycWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def band(conn, _params) do
    posts = Amsyc.Posts.list_posts()

    conn
    |> assign(:posts, posts)
    |> render(:band)
  end

  def admin(conn, _params) do
    text(conn, "This is the admin page")
  end
end
