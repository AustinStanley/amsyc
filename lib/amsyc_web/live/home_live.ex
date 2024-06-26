defmodule AmsycWeb.HomeLive do
  alias Amsyc.Accounts
  use AmsycWeb, :live_view

  alias Amsyc.Posts
  alias Amsyc.Posts.Post

  alias Amsyc.Images

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="feed" class="flex flex-col gap-20 pb-96" phx-update="stream">
      <div
        :for={{dom_id, post} <- @streams.posts}
        id={dom_id}
        class="flex flex-col gap-2 w-full mx-auto text-brand bg-zinc-900 bg-opacity-80 p-4 border-l-8 border-l-blue-500"
      >
        <div class="flex w-full bg-zinc-200 justify-center items-center px-4 py-3 text-zinc-900 text-3xl font-sans font-thin tracking-[0.75em]">
          <%= post.title %>
        </div>
        <img :if={post.image} src={Images.get_image!(post.image).path} class="border-8 border-zinc-400" />
        <div :if={post.embedded_media}>
          <%= raw(post.embedded_media) %>
        </div>
        <div class="p-2 border border-zinc-200 font-light font-mono text-zinc-200">
          <%= raw(post.body) %>
        </div>
      </div>
    </div>

    <.modal id="create-post-modal">
      <div id="form" phx-update="ignore">
        <.simple_form for={@form} phx-change="validate" phx-submit="save-post">
          <label for={@uploads.image.ref}>Image</label>
          <br />
          <.live_file_input upload={@uploads.image} />
          <.input field={@form[:title]} type="text" label="Title" />
          <.input
            field={@form[:embedded_media]}
            type="text"
            label="Embed Code (YouTube, ReverbNation, etc.)"
          />
          <.input field={@form[:body]} type="hidden" label="Body" id="trix-editor" />
          <trix-editor class="trix-content" input="trix-editor"></trix-editor>
          <.button type="submit" phx-disable-with="Saving...">Submit</.button>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      user_token =
        case session do
          %{"user_token" => token} -> token
          _ -> nil
        end

      user_id = if user_token, do: Accounts.get_user_by_session_token(user_token), else: nil

      form =
        %Post{}
        |> Post.changeset(%{})
        |> to_form(as: "post")

      socket =
        socket
        |> assign(form: form, logged_in: !!user_token, user_id: user_id, loading: false)
        |> allow_upload(:image, accept: ~w(.png .jpg), max_entries: 1)
        |> stream(:posts, Posts.list_posts())

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-post", %{"post" => post_params}, socket) do
    %{user_id: user} = socket.assigns

    {:ok, image} =
      %{path: List.first(consume_files(socket))}
      |> Images.create_image()

    post_params
    |> Map.put("user", user.id)
    |> Map.put("image", image.id)
    |> Posts.create_post()
    |> case do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully!")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      # TODO: do something more helpful on error
      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, socket}
    end
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:amsyc), "static", "uploads", Path.basename(path)])
      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end
end
